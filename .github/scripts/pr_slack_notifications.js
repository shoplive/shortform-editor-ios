module.exports = async ({ github, context, core, fetch: providedFetch }) => {
  const fetch = providedFetch || globalThis.fetch;
  const slackBotToken = process.env.SLACK_BOT_TOKEN;
  if (!slackBotToken) {
    core.warning("SLACK_BOT_TOKEN is missing or unavailable for this event. Skipping Slack notification.");
    return;
  }
  
  const owner = context.repo.owner;
  const repo = context.repo.repo;
  const eventName = context.eventName;
  const action = context.payload.action;
  const { createHash } = require("crypto");
  
  async function resolvePrPayload() {
    if (eventName === "issue_comment") {
      const issue = context.payload.issue;
      if (!issue || !issue.pull_request) {
        return null;
      }
  
      const prResponse = await github.rest.pulls.get({
        owner,
        repo,
        pull_number: issue.number,
      });
      return prResponse.data;
    }
  
    return context.payload.pull_request || null;
  }
  
  const pr = await resolvePrPayload();
  if (!pr) {
    core.info("No pull_request payload. Skipping.");
    return;
  }
  const baseRepoFullName = `${owner}/${repo}`.toLowerCase();
  const headRepoFullName = String(pr.head?.repo?.full_name || baseRepoFullName).toLowerCase();
  const isForkPr = headRepoFullName !== baseRepoFullName;
  
  const channel = process.env.SLACK_CHANNEL_ID || process.env.SLACK_CHANNEL_ID_VAR;
  if (!channel) {
    core.setFailed("Slack channel is not configured. Set SLACK_CHANNEL_ID secret or vars.SLACK_CHANNEL_ID.");
    return;
  }
  
  const issueNumber = pr.number;
  const runUrl = `${context.serverUrl || "https://github.com"}/${owner}/${repo}/actions/runs/${context.runId}`;
  const runEventLabel = `${eventName}/${action || "none"}`;
  const METADATA_HUMAN_TITLE = "Slack PR 알림 메타데이터";
  const METADATA_MARKER_PREFIX = "<!-- slack-pr-notify-metadata:v2:";
  const METADATA_MARKER_REGEX = /<!--\s*slack-pr-notify-metadata:v2:([A-Za-z0-9_-]+)\s*-->/;
  const LEGACY_METADATA_MARKER = "<!-- slack-pr-notify-metadata:v1 -->";
  const LEGACY_THREAD_MARKER_PREFIX = "<!-- slack-pr-thread-ts:";
  const LEGACY_THREAD_MARKER_REGEX = /<!--\s*slack-pr-thread-ts:([0-9.]+)\s*-->/;
  const LEGACY_SUMMARY_MARKER = "<!-- ai-summary-posted:v1 -->";
  const LEGACY_AI_REVIEW_REQUESTED_MARKER = "<!-- ai-review-requested:v1 -->";
  const LEGACY_AI_REVIEW_COMPLETED_REGEX = /<!--\s*ai-review-completed:([^:>]+):([^ >]+)\s*-->/;
  const LEGACY_REVIEW_REQUEST_NOTIFIED_REGEX = /<!--\s*review-request-notified:v1:([a-f0-9]+)\s*-->/i;
  
  let issueCommentsCache = null;
  let metadataCommentCache = null;
  let metadataCache = null;
  let metadataCommentFormatNeedsUpgrade = false;
  let threadTsCache = null;
  
  function nowIso() {
    return new Date().toISOString();
  }
  
  function cloneObject(value) {
    return JSON.parse(JSON.stringify(value));
  }
  
  function uniqueSortedStrings(values) {
    return Array.from(
      new Set(
        (values || [])
          .map((item) => String(item || "").trim())
          .filter(Boolean)
      )
    ).sort();
  }
  
  function uniqueSortedLower(values) {
    return Array.from(
      new Set(
        (values || [])
          .map((item) => String(item || "").trim().toLowerCase())
          .filter(Boolean)
      )
    ).sort();
  }
  
  function buildDefaultMetadata() {
    return {
      version: 1,
      threadTs: null,
      summaryPosted: false,
      summaryPostedAt: null,
      aiReviewRequested: null,
      aiReviewCompletedKeys: [],
      reviewRequestNotifiedKeys: [],
      updatedAt: null,
    };
  }
  
  function normalizeMetadata(raw) {
    const metadata = raw && typeof raw === "object" ? cloneObject(raw) : buildDefaultMetadata();
    const normalized = buildDefaultMetadata();
  
    normalized.threadTs = typeof metadata.threadTs === "string" && metadata.threadTs.trim() ? metadata.threadTs.trim() : null;
    normalized.summaryPosted = Boolean(metadata.summaryPosted);
    normalized.summaryPostedAt =
      typeof metadata.summaryPostedAt === "string" && metadata.summaryPostedAt.trim()
        ? metadata.summaryPostedAt.trim()
        : null;
  
    if (metadata.aiReviewRequested && typeof metadata.aiReviewRequested === "object") {
      const trigger = String(metadata.aiReviewRequested.trigger || "").trim();
      const status = String(metadata.aiReviewRequested.status || "").trim();
      const at = String(metadata.aiReviewRequested.at || "").trim();
      if (trigger || status || at) {
        normalized.aiReviewRequested = {
          trigger: trigger || "unknown",
          status: status || "unknown",
          at: at || null,
        };
      }
    }
  
    normalized.aiReviewCompletedKeys = uniqueSortedStrings(metadata.aiReviewCompletedKeys).slice(0, 500);
    normalized.reviewRequestNotifiedKeys = uniqueSortedStrings(metadata.reviewRequestNotifiedKeys).slice(0, 500);
    normalized.updatedAt = typeof metadata.updatedAt === "string" && metadata.updatedAt.trim() ? metadata.updatedAt.trim() : null;
  
    return normalized;
  }
  
  function parseLegacyThreadTs(body) {
    if (!body) {
      return null;
    }
    const match = body.match(LEGACY_THREAD_MARKER_REGEX);
    return match ? match[1] : null;
  }
  
  function encodeBase64Url(text) {
    return Buffer.from(String(text || ""), "utf8")
      .toString("base64")
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/g, "");
  }
  
  function decodeBase64Url(text) {
    const normalized = String(text || "")
      .replace(/-/g, "+")
      .replace(/_/g, "/");
    const padLength = normalized.length % 4 === 0 ? 0 : 4 - (normalized.length % 4);
    const padded = normalized + "=".repeat(padLength);
    return Buffer.from(padded, "base64").toString("utf8");
  }
  
  function isMetadataCommentBody(body) {
    const text = String(body || "");
    return text.includes(METADATA_MARKER_PREFIX) || text.includes(LEGACY_METADATA_MARKER);
  }
  
  function parseMetadataCommentBody(body) {
    if (!body) {
      return buildDefaultMetadata();
    }
  
    const v2Match = body.match(METADATA_MARKER_REGEX);
    if (v2Match && v2Match[1]) {
      try {
        const decoded = decodeBase64Url(v2Match[1]);
        return normalizeMetadata(JSON.parse(decoded));
      } catch (error) {
        core.warning(`Failed to parse v2 metadata comment: ${error.message}`);
      }
    }
  
    if (body.includes(LEGACY_METADATA_MARKER)) {
      const fencedMatch = body.match(/```json\s*([\s\S]*?)```/i);
      const rawJson = fencedMatch
        ? fencedMatch[1]
        : body.slice(body.indexOf(LEGACY_METADATA_MARKER) + LEGACY_METADATA_MARKER.length);
      try {
        return normalizeMetadata(JSON.parse(rawJson));
      } catch (error) {
        core.warning(`Failed to parse legacy metadata comment JSON: ${error.message}`);
      }
    }
  
    return buildDefaultMetadata();
  }
  
  function buildMetadataCommentBody(metadata) {
    const normalized = normalizeMetadata(metadata);
    normalized.updatedAt = nowIso();
    const encoded = encodeBase64Url(JSON.stringify(normalized));
    const summaryState = normalized.summaryPosted ? "sent" : "not_sent";
    const aiReviewState = normalized.aiReviewRequested?.status || "none";
    const threadState = normalized.threadTs ? "set" : "missing";
  
    return [
      `**${METADATA_HUMAN_TITLE}**`,
      "자동 생성 코멘트입니다. Slack 스레드 연결 및 중복 알림 방지 상태를 저장합니다.",
      `최근 실행: \`${runEventLabel}\` · [workflow run](${runUrl})`,
      `상태: summary=${summaryState}, ai_review=${aiReviewState}, thread_ts=${threadState}`,
      `${METADATA_MARKER_PREFIX}${encoded} -->`,
    ].join("\n");
  }
  
  function upsertIssueCommentCache(comment) {
    if (!issueCommentsCache || !comment || !comment.id) {
      return;
    }
    const index = issueCommentsCache.findIndex((item) => item.id === comment.id);
    if (index >= 0) {
      issueCommentsCache[index] = comment;
    } else {
      issueCommentsCache.push(comment);
    }
  }
  
  async function listIssueComments(force = false) {
    if (!force && Array.isArray(issueCommentsCache)) {
      return issueCommentsCache;
    }
  
    issueCommentsCache = await github.paginate(github.rest.issues.listComments, {
      owner,
      repo,
      issue_number: issueNumber,
      per_page: 100,
    });
    return issueCommentsCache;
  }
  
  async function findIssueCommentByPredicate(predicate) {
    const comments = await listIssueComments();
    return comments.find((comment) => typeof comment.body === "string" && predicate(comment.body));
  }
  
  function extractLegacyMetadataFromComments(comments) {
    const legacy = {
      threadTs: null,
      summaryPosted: false,
      aiReviewRequested: false,
      aiReviewCompletedKeys: new Set(),
      reviewRequestNotifiedKeys: new Set(),
    };
  
    for (const comment of comments) {
      const body = typeof comment.body === "string" ? comment.body : "";
      if (!body) {
        continue;
      }
  
      if (!legacy.threadTs && body.includes(LEGACY_THREAD_MARKER_PREFIX)) {
        const ts = parseLegacyThreadTs(body);
        if (ts) {
          legacy.threadTs = ts;
        }
      }
  
      if (body.includes(LEGACY_SUMMARY_MARKER)) {
        legacy.summaryPosted = true;
      }
  
      if (body.includes(LEGACY_AI_REVIEW_REQUESTED_MARKER)) {
        legacy.aiReviewRequested = true;
      }
  
      const completedMatch = body.match(LEGACY_AI_REVIEW_COMPLETED_REGEX);
      if (completedMatch) {
        legacy.aiReviewCompletedKeys.add(`${completedMatch[1]}:${completedMatch[2]}`);
      }
  
      const notifiedMatch = body.match(LEGACY_REVIEW_REQUEST_NOTIFIED_REGEX);
      if (notifiedMatch) {
        legacy.reviewRequestNotifiedKeys.add(`digest:${notifiedMatch[1].toLowerCase()}`);
      }
    }
  
    return legacy;
  }
  
  async function loadMetadata() {
    if (metadataCache) {
      return metadataCache;
    }
  
    const comments = await listIssueComments();
    metadataCommentCache = comments.find(
      (comment) => typeof comment.body === "string" && isMetadataCommentBody(comment.body)
    ) || null;
    const metadataBodyText = String(metadataCommentCache?.body || "");
    metadataCommentFormatNeedsUpgrade = Boolean(
      metadataBodyText &&
        (metadataBodyText.includes(LEGACY_METADATA_MARKER) ||
          !metadataBodyText.includes(METADATA_HUMAN_TITLE))
    );
  
    metadataCache = metadataCommentCache
      ? parseMetadataCommentBody(metadataCommentCache.body)
      : buildDefaultMetadata();
  
    const legacy = extractLegacyMetadataFromComments(comments);
    if (!metadataCache.threadTs && legacy.threadTs) {
      metadataCache.threadTs = legacy.threadTs;
    }
    if (legacy.summaryPosted) {
      metadataCache.summaryPosted = true;
    }
    if (!metadataCache.aiReviewRequested && legacy.aiReviewRequested) {
      metadataCache.aiReviewRequested = {
        trigger: "legacy-marker",
        status: "unknown",
        at: null,
      };
    }
    metadataCache.aiReviewCompletedKeys = uniqueSortedStrings([
      ...metadataCache.aiReviewCompletedKeys,
      ...legacy.aiReviewCompletedKeys,
    ]).slice(0, 500);
    metadataCache.reviewRequestNotifiedKeys = uniqueSortedStrings([
      ...metadataCache.reviewRequestNotifiedKeys,
      ...legacy.reviewRequestNotifiedKeys,
    ]).slice(0, 500);
  
    metadataCache = normalizeMetadata(metadataCache);
    return metadataCache;
  }
  
  async function persistMetadata() {
    const metadataBody = buildMetadataCommentBody(metadataCache || buildDefaultMetadata());
  
    if (metadataCommentCache) {
      const response = await github.rest.issues.updateComment({
        owner,
        repo,
        comment_id: metadataCommentCache.id,
        body: metadataBody,
      });
      metadataCommentCache = response.data;
      metadataCommentFormatNeedsUpgrade = false;
      upsertIssueCommentCache(response.data);
      return;
    }
  
    const response = await github.rest.issues.createComment({
      owner,
      repo,
      issue_number: issueNumber,
      body: metadataBody,
    });
    metadataCommentCache = response.data;
    metadataCommentFormatNeedsUpgrade = false;
    upsertIssueCommentCache(response.data);
  }
  
  async function updateMetadata(mutator) {
    const current = await loadMetadata();
    const before = JSON.stringify(normalizeMetadata(current));
    const draft = cloneObject(current);
    const next = mutator ? await mutator(draft) : draft;
    metadataCache = normalizeMetadata(next || draft);
    const after = JSON.stringify(metadataCache);
  
    if (before !== after || !metadataCommentCache || metadataCommentFormatNeedsUpgrade) {
      await persistMetadata();
    }
    return metadataCache;
  }
  
  function isCopilotReviewer(login) {
    if (!login) {
      return false;
    }
    return login.toLowerCase().includes("copilot");
  }
  
  async function slackApi(method, payload) {
    const response = await fetch(`https://slack.com/api/${method}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${slackBotToken}`,
        "Content-Type": "application/json; charset=utf-8",
      },
      body: JSON.stringify(payload),
    });
  
    const data = await response.json();
    if (!data.ok) {
      throw new Error(`Slack API ${method} failed: ${data.error}`);
    }
    return data;
  }
  
  function buildRootText() {
    const prLink = `<${pr.html_url}|#${pr.number} ${pr.title}>`;
    const author = pr.user?.login || "unknown";
    const baseRef = pr.base?.ref || "unknown";
    const headRef = pr.head?.ref || "unknown";
  
    return [
      "*PR 생성*",
      `*제목* ${prLink}`,
      `*작성자* ${author}`,
      `*브랜치* ${headRef} -> ${baseRef}`,
      "이 스레드에서 리뷰/승인/머지 업데이트를 계속 안내합니다.",
    ].join("\n");
  }
  
  async function ensureThreadTs() {
    if (threadTsCache) {
      return threadTsCache;
    }
  
    const metadata = await loadMetadata();
    if (metadata.threadTs) {
      threadTsCache = metadata.threadTs;
      return threadTsCache;
    }
  
    const rootMessage = await slackApi("chat.postMessage", {
      channel,
      text: buildRootText(),
      unfurl_links: false,
      unfurl_media: false,
    });
  
    const threadTs = rootMessage.ts;
    if (!threadTs) {
      throw new Error("Slack message was sent, but thread ts was missing.");
    }
  
    threadTsCache = threadTs;
    await updateMetadata((draft) => {
      draft.threadTs = threadTs;
      return draft;
    });
    return threadTs;
  }
  
  async function postThreadMessage(text) {
    const threadTs = await ensureThreadTs();
    await slackApi("chat.postMessage", {
      channel,
      thread_ts: threadTs,
      reply_broadcast: false,
      text,
      unfurl_links: false,
      unfurl_media: false,
    });
  }
  
  function parseUserMap() {
    const raw = (process.env.SLACK_USER_MAP_JSON || "").trim();
    if (!raw) {
      return {};
    }
    try {
      const parsed = JSON.parse(raw);
      if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
        return parsed;
      }
    } catch (error) {
      core.warning(`SLACK_USER_MAP_JSON JSON parse failed: ${error.message}`);
    }
  
    // Fallback parser for non-JSON formats, e.g.:
    // yong-ios=U12345
    // kio-shoplive:U67890
    const fallback = {};
    const chunks = raw
      .replace(/[{}]/g, "")
      .split(/\r?\n|,/)
      .map((line) => line.trim())
      .filter(Boolean);
  
    for (const chunk of chunks) {
      const match = chunk.match(/^"?([^":=]+)"?\s*[:=]\s*"?([^"]+)"?$/);
      if (!match) {
        continue;
      }
      const key = String(match[1] || "").trim();
      const value = String(match[2] || "").trim();
      if (key && value) {
        fallback[key] = value;
      }
    }
  
    if (Object.keys(fallback).length > 0) {
      core.info(`SLACK_USER_MAP_JSON fallback parser applied with ${Object.keys(fallback).length} entries.`);
      return fallback;
    }
    return {};
  }
  
  function normalizeLoginKey(value) {
    if (!value) {
      return "";
    }
    return String(value).toLowerCase().replace(/[^a-z0-9]/g, "");
  }
  
  function normalizeSlackUserId(value) {
    if (!value) {
      return null;
    }
    const text = String(value).trim();
    const mentionMatch = text.match(/^<@([A-Z0-9]+)>$/i);
    if (mentionMatch) {
      return mentionMatch[1].toUpperCase();
    }
    const idMatch = text.match(/^[A-Z0-9]+$/i);
    if (idMatch) {
      return text.toUpperCase();
    }
    return null;
  }
  
  function findSlackUserId(userMap, githubLogin) {
    if (!githubLogin) {
      return null;
    }
    const directValue = userMap[githubLogin];
    const normalizedDirect = normalizeSlackUserId(directValue);
    if (normalizedDirect) {
      return normalizedDirect;
    }
  
    const lowerLogin = githubLogin.toLowerCase();
    for (const [key, value] of Object.entries(userMap)) {
      if (key.toLowerCase() === lowerLogin) {
        const normalized = normalizeSlackUserId(value);
        if (normalized) {
          return normalized;
        }
      }
    }
  
    // Fuzzy fallback for aliases like yong-ios <-> yong
    const loginNorm = normalizeLoginKey(githubLogin);
    for (const [key, value] of Object.entries(userMap)) {
      const keyNorm = normalizeLoginKey(key);
      if (!keyNorm || !loginNorm) {
        continue;
      }
      if (
        keyNorm === loginNorm ||
        (keyNorm.length >= 3 && loginNorm.startsWith(keyNorm)) ||
        (loginNorm.length >= 3 && keyNorm.startsWith(loginNorm))
      ) {
        const normalized = normalizeSlackUserId(value);
        if (normalized) {
          return normalized;
        }
      }
    }
    return null;
  }
  
  function resolveSlackMentionsFromGitHubLogins(userMap, githubLogins) {
    const mentions = [];
    const unmapped = [];
    const seen = new Set();
    for (const login of githubLogins) {
      const slackUserId = findSlackUserId(userMap, login);
      if (slackUserId && !seen.has(slackUserId)) {
        mentions.push(`<@${slackUserId}>`);
        seen.add(slackUserId);
      } else if (!slackUserId) {
        unmapped.push(login);
      }
    }
    return { mentions, unmapped };
  }
  
  function buildReviewRequestNotifiedKey(githubLogins, teamSlugs) {
    const users = uniqueSortedLower(githubLogins).map((login) => `user:${login}`);
    const teams = uniqueSortedLower(teamSlugs).map((slug) => `team:${slug}`);
    const canonicalParts = [...users, ...teams].sort();
    if (canonicalParts.length === 0) {
      return null;
    }
    const canonical = canonicalParts.join("|");
    const digest = createHash("sha1").update(canonical).digest("hex").slice(0, 12);
    return `digest:${digest}`;
  }
  
  async function markReviewRequestNotified(key) {
    if (!key) {
      return true;
    }
  
    let created = false;
    await updateMetadata((draft) => {
      const existing = new Set(draft.reviewRequestNotifiedKeys || []);
      if (!existing.has(key)) {
        existing.add(key);
        draft.reviewRequestNotifiedKeys = Array.from(existing).sort();
        created = true;
      }
      return draft;
    });
    return created;
  }
  
  async function markAiReviewCompleted(provider, reviewId) {
    const key = `${provider}:${reviewId}`;
    let created = false;
    await updateMetadata((draft) => {
      const existing = new Set(draft.aiReviewCompletedKeys || []);
      if (!existing.has(key)) {
        existing.add(key);
        draft.aiReviewCompletedKeys = Array.from(existing).sort();
        created = true;
      }
      return draft;
    });
    return created;
  }
  
  function reviewStateLabel(state) {
    switch (state) {
      case "approved":
        return "승인";
      case "changes_requested":
        return "수정 요청";
      case "commented":
        return "코멘트";
      case "dismissed":
        return "무효화";
      default:
        return state || "알 수 없음";
    }
  }
  
  function stripMarkdownLine(line) {
    return String(line || "")
      .replace(/^#{1,6}\s*/g, "")
      .replace(/^\d+[.)]\s*/g, "")
      .replace(/^- \[[ xX]\]\s*/g, "")
      .replace(/^\s*[-*]\s+/g, "")
      .replace(/^>\s*/g, "")
      .replace(/\[ai-review\]/gi, "")
      .replace(/\/ai-review/gi, "")
      .replace(/\[(.*?)\]\((.*?)\)/g, "$1")
      .replace(/[*_`~]/g, "")
      .replace(/\s+/g, " ")
      .trim();
  }
  
  function extractSummaryLines(body, maxLines = 3) {
    const skipPatterns = [
      /^세줄 요약$/i,
      /^feature link$/i,
      /^pr 간단하게 설명 해주세요\.?$/i,
      /^pr 에 포함 될 유틸 중 유용하게 쓰일 상황 있다면 말해주세요\.?$/i,
      /^mention$/i,
      /^테스트 진행 여부$/i,
      /^없음$/i,
    ];
  
    const lines = String(body || "")
      .split(/\r?\n/)
      .map(stripMarkdownLine)
      .filter((line) => line.length > 0)
      .filter((line) => !line.startsWith("@"))
      .filter((line) => !skipPatterns.some((pattern) => pattern.test(line)))
      .filter((line) => !/^(개발 서버 테스트 완료|실서버 테스트 완료)$/i.test(line));
  
    return lines.slice(0, maxLines);
  }
  
  function normalizeSummaryLines(text, maxLines = 5) {
    return String(text || "")
      .split(/\r?\n/)
      .map(stripMarkdownLine)
      .filter(Boolean)
      .slice(0, maxLines);
  }

  function extractCopilotOverviewLines(body, maxLines = 4) {
    const skipPatterns = [
      /^pull request overview$/i,
      /^changes:?$/i,
      /^you can also share your feedback on copilot code review\.?$/i,
      /^take the survey\.?$/i,
    ];

    return String(body || "")
      .split(/\r?\n/)
      .map(stripMarkdownLine)
      .filter(Boolean)
      .filter((line) => !skipPatterns.some((pattern) => pattern.test(line)))
      .filter((line) => !/feedback on copilot code review/i.test(line))
      .slice(0, maxLines);
  }

  async function resolveReviewBody(review) {
    const inlineBody = String(review?.body || "").trim();
    if (inlineBody) {
      return inlineBody;
    }

    const reviewId = review?.id;
    if (!reviewId) {
      return "";
    }

    try {
      const response = await github.rest.pulls.getReview({
        owner,
        repo,
        pull_number: issueNumber,
        review_id: reviewId,
      });
      return String(response.data?.body || "").trim();
    } catch (error) {
      core.warning(`Failed to load review body(${reviewId}): ${error.message}`);
      return "";
    }
  }
  
  function buildDeterministicDiffSummary(files) {
    if (!files.length) {
      return ["변경 파일이 없습니다."];
    }
  
    const ranked = files
      .slice()
      .sort((a, b) => (b.changes || 0) - (a.changes || 0))
      .slice(0, 5);
  
    return ranked.map((file) => {
      const from = file.status === "renamed" && file.previous_filename ? ` (from ${file.previous_filename})` : "";
      return `${file.filename} [${file.status || "modified"}] +${file.additions || 0}/-${file.deletions || 0}${from}`;
    });
  }
  
  function maskSensitiveInPatch(text) {
    let masked = String(text || "");
    const patterns = [
      {
        regex: /-----BEGIN [^-]*PRIVATE KEY-----[\s\S]*?-----END [^-]*PRIVATE KEY-----/g,
        replacement: "[REDACTED_PRIVATE_KEY]",
      },
      {
        regex: /\bgh[pousr]_[A-Za-z0-9]{20,}\b/g,
        replacement: "[REDACTED_GITHUB_TOKEN]",
      },
      {
        regex: /\bxox[baprs]-[A-Za-z0-9-]{10,}\b/g,
        replacement: "[REDACTED_SLACK_TOKEN]",
      },
      {
        regex: /\bAKIA[0-9A-Z]{16}\b/g,
        replacement: "[REDACTED_AWS_ACCESS_KEY]",
      },
      {
        regex: /\bAIza[0-9A-Za-z\\-_]{35}\b/g,
        replacement: "[REDACTED_GOOGLE_API_KEY]",
      },
    ];
  
    for (const rule of patterns) {
      masked = masked.replace(rule.regex, rule.replacement);
    }
    return masked;
  }
  
  function extensionFromFilename(filename) {
    const name = String(filename || "");
    const lastSegment = name.split("/").pop() || "";
    if (!lastSegment.includes(".")) {
      return "(no-ext)";
    }
    const ext = lastSegment.split(".").pop();
    return ext ? `.${ext.toLowerCase()}` : "(no-ext)";
  }
  
  function buildDiffStatsContext(files, maxFiles = 25, maxExts = 8) {
    const additions = files.reduce((sum, file) => sum + (file.additions || 0), 0);
    const deletions = files.reduce((sum, file) => sum + (file.deletions || 0), 0);
  
    const statusCounts = {};
    const extCounts = {};
    for (const file of files) {
      const status = file.status || "modified";
      statusCounts[status] = (statusCounts[status] || 0) + 1;
  
      const ext = extensionFromFilename(file.filename);
      extCounts[ext] = (extCounts[ext] || 0) + 1;
    }
  
    const statusLine = Object.entries(statusCounts)
      .sort((a, b) => a[0].localeCompare(b[0]))
      .map(([status, count]) => `${status}:${count}`)
      .join(", ");
  
    const extLine = Object.entries(extCounts)
      .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
      .slice(0, maxExts)
      .map(([ext, count]) => `${ext}:${count}`)
      .join(", ");
  
    const ranked = files
      .slice()
      .sort((a, b) => (b.changes || 0) - (a.changes || 0))
      .slice(0, maxFiles);
  
    const fileLines = ranked.map((file, idx) => {
      const from = file.status === "renamed" && file.previous_filename ? ` from=${file.previous_filename}` : "";
      return `#${idx + 1} ${file.filename} [${file.status || "modified"}] +${file.additions || 0}/-${file.deletions || 0}${from}`;
    });
  
    return [
      `changed_files=${files.length}`,
      `total_additions=${additions}`,
      `total_deletions=${deletions}`,
      `status_breakdown=${statusLine || "none"}`,
      `top_extensions=${extLine || "none"}`,
      "",
      "top_changed_files:",
      ...fileLines,
    ].join("\n");
  }
  
  function buildDiffContext(files, maxFiles = 20, maxPatchLines = 120, maxChars = 18000) {
    const ranked = files
      .slice()
      .sort((a, b) => (b.changes || 0) - (a.changes || 0))
      .slice(0, maxFiles);
  
    const chunks = ranked.map((file, idx) => {
      const header = `#${idx + 1} ${file.filename} [${file.status || "modified"}] +${file.additions || 0}/-${file.deletions || 0}`;
      if (!file.patch) {
        return `${header}\n(binary or patch omitted)`;
      }
      const maskedPatch = maskSensitiveInPatch(file.patch);
      const patchLines = maskedPatch.split(/\r?\n/).slice(0, maxPatchLines).join("\n");
      return `${header}\n${patchLines}`;
    });
  
    const text = chunks.join("\n\n");
    if (text.length <= maxChars) {
      return text;
    }
    return `${text.slice(0, maxChars)}\n\n[diff context truncated]`;
  }

  function compactText(value, maxLength = 220) {
    const text = String(value || "").replace(/\s+/g, " ").trim();
    if (!text) {
      return "";
    }
    if (text.length <= maxLength) {
      return text;
    }
    return `${text.slice(0, maxLength)}...`;
  }

  async function parseInferenceErrorResponse(response) {
    const status = response?.status || 0;
    let detail = "";

    try {
      const raw = await response.text();
      if (raw) {
        try {
          const parsed = JSON.parse(raw);
          detail =
            parsed?.error?.message ||
            parsed?.message ||
            parsed?.error ||
            raw;
        } catch (_) {
          detail = raw;
        }
      }
    } catch (_) {
      // no-op
    }

    const compactDetail = compactText(detail, 200);
    const withStatus = compactDetail ? `HTTP ${status}: ${compactDetail}` : `HTTP ${status}`;

    if (status === 401 || status === 403) {
      return `권한 오류 (${withStatus}) - workflow permissions에 \`models: read\`가 있는지 확인하세요.`;
    }
    if (status === 404) {
      return `모델/엔드포인트 접근 실패 (${withStatus})`;
    }
    if (status === 422) {
      return `요청 형식 또는 모델 접근 권한 오류 (${withStatus})`;
    }
    if (status >= 500) {
      return `GitHub Models 서버 오류 (${withStatus})`;
    }
    return `AI 요약 API 실패 (${withStatus})`;
  }
  
  async function buildCopilotDiffSummary(files) {
    const modelsToken =
      (process.env.MODELS_API_TOKEN || "").trim() ||
      (process.env.GITHUB_TOKEN || "").trim();
    if (!modelsToken) {
      const reason = "MODELS_API_TOKEN/GITHUB_TOKEN이 없어 AI 요약을 건너뜀";
      core.warning(reason);
      return { ok: false, contextMode: "stats", reason };
    }
  
    if (!files.length) {
      return { ok: false, contextMode: "stats", reason: "변경 파일이 없음" };
    }
  
    const configuredModel = (process.env.COPILOT_SUMMARY_MODEL || "openai/gpt-4o-mini").trim();
    const modelCandidates = Array.from(
      new Set([configuredModel, "openai/gpt-4o-mini", "openai/gpt-4o"])
    ).filter(Boolean);

    const requestedContextMode = String(process.env.AI_SUMMARY_CONTEXT_MODE || "auto")
      .trim()
      .toLowerCase();
    let contextMode = requestedContextMode;
    if (!["auto", "full", "stats"].includes(contextMode)) {
      contextMode = "auto";
    }
    if (contextMode === "auto") {
      contextMode = isForkPr ? "stats" : "full";
    }
  
    if (isForkPr && contextMode === "full") {
      core.warning("Fork PR with full diff AI context. Review policy before using this mode.");
    }
  
    const diffContext =
      contextMode === "full"
        ? buildDiffContext(files, 20, 120, 18000)
        : buildDiffStatsContext(files, 25, 8);
    if (!diffContext) {
      return { ok: false, contextMode, reason: "AI 요약용 컨텍스트 생성 실패" };
    }
  
    const prompt =
      contextMode === "full"
        ? [
            "아래 PR diff(일부/마스킹 포함)를 바탕으로 4~5줄로 핵심 변경 사항을 한국어로 요약하세요.",
            "요구사항:",
            "- PR 본문이 아니라 diff 근거로 작성",
            "- 기능 변화, 리스크, 테스트 포인트를 각각 최소 1개 포함",
            "- 과장 없이 사실 중심",
            "",
            diffContext,
          ].join("\n")
        : [
            "아래 PR 변경 통계/파일 목록을 바탕으로 4~5줄로 핵심 변경 사항을 한국어로 요약하세요.",
            "요구사항:",
            "- 코드 원문/patch가 없으므로 파일명/변경량/상태만 근거로 작성",
            "- 기능 변화, 리스크, 테스트 포인트를 각각 최소 1개 포함",
            "- 과장 없이 사실 중심",
            "",
            diffContext,
          ].join("\n");
  
    let lastReason = "AI 요약 생성 실패";
    for (const model of modelCandidates) {
      try {
        const response = await fetch("https://models.github.ai/inference/chat/completions", {
          method: "POST",
          headers: {
            Authorization: `Bearer ${modelsToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
            "X-GitHub-Api-Version": "2022-11-28",
          },
          body: JSON.stringify({
            model,
            temperature: 0.2,
            max_tokens: 280,
            messages: [
              {
                role: "system",
                content:
                  "You are GitHub Copilot-style PR reviewer. Summarize only what is evidenced by the diff.",
              },
              {
                role: "user",
                content: prompt,
              },
            ],
          }),
        });

        if (!response.ok) {
          lastReason = await parseInferenceErrorResponse(response);
          core.warning(`AI diff summary failed with model '${model}': ${lastReason}`);
          if (response.status === 401 || response.status === 403) {
            break;
          }
          continue;
        }

        const data = await response.json();
        const content = data?.choices?.[0]?.message?.content;
        if (typeof content !== "string" || !content.trim()) {
          lastReason = `모델 '${model}' 응답이 비어 있음`;
          core.warning(lastReason);
          continue;
        }

        return {
          ok: true,
          text: content.trim(),
          contextMode,
          model,
        };
      } catch (error) {
        lastReason = `모델 '${model}' 호출 예외: ${compactText(error.message, 160)}`;
        core.warning(`AI diff summary failed: ${lastReason}`);
      }
    }

    return { ok: false, contextMode, reason: lastReason };
  }
  
  function isAiReviewRequestedFromPrBody(body) {
    if (!body) {
      return false;
    }
    return /\[ai-review\]/i.test(body);
  }
  
  function isAiReviewCommandComment(body) {
    if (!body) {
      return false;
    }
    return body.trim().toLowerCase().startsWith("/ai-review");
  }
  
  async function requestAiReviewerIfConfigured() {
    const aiReviewerLogin = (process.env.AI_REVIEWER_LOGIN || "").trim();
    if (!aiReviewerLogin) {
      return { status: "not_configured", label: "리뷰어 자동 지정은 설정되지 않음(AI_REVIEWER_LOGIN 없음)" };
    }
  
    try {
      await github.rest.pulls.requestReviewers({
        owner,
        repo,
        pull_number: issueNumber,
        reviewers: [aiReviewerLogin],
      });
      return { status: "requested", label: `AI 리뷰어 자동 지정 완료: \`${aiReviewerLogin}\`` };
    } catch (error) {
      core.warning(`Failed to request AI reviewer: ${error.message}`);
      return {
        status: "failed",
        label: `AI 리뷰어 자동 지정 실패: \`${aiReviewerLogin}\` (${error.message})`,
      };
    }
  }
  
  async function listPrFiles() {
    return github.paginate(github.rest.pulls.listFiles, {
      owner,
      repo,
      pull_number: issueNumber,
      per_page: 100,
    });
  }
  
  async function buildPrSummaryText() {
    const files = await listPrFiles();
    const additions = files.reduce((sum, file) => sum + (file.additions || 0), 0);
    const deletions = files.reduce((sum, file) => sum + (file.deletions || 0), 0);
    const changedFiles = files.length;
  
    const areas = new Set();
    for (const file of files) {
      const filename = file.filename || "";
      const area = filename.includes("/") ? filename.split("/")[0] : filename;
      if (area) {
        areas.add(area);
      }
    }
  
    const topFiles = files
      .slice()
      .sort((a, b) => (b.changes || 0) - (a.changes || 0))
      .slice(0, 5)
      .map((file) => file.filename);
  
    const areaList = Array.from(areas).slice(0, 5);
    const prLink = `<${pr.html_url}|#${pr.number} ${pr.title}>`;
    const bodySummaryLines = extractSummaryLines(pr.body, 5);
  
    const lines = [
      "*PR 요약*",
      `*PR* ${prLink}`,
      `*변경 파일* ${changedFiles}개 (+${additions} / -${deletions})`,
      `*주요 영역* ${areaList.length ? areaList.join(", ") : "분류 불가"}`,
      `*변경 큰 파일* ${topFiles.length ? topFiles.join(", ") : "없음"}`,
      "",
      "*PR 본문 참고*",
    ];

    if (bodySummaryLines.length) {
      lines.push(...bodySummaryLines.map((line) => `- ${line}`));
      lines.push("- 상세 내용은 PR 본문(Description)에서 확인해 주세요.");
    } else {
      lines.push("- PR 본문 요약이 비어 있습니다.");
      lines.push("- 상세 변경 사항은 PR 본문(Description)과 파일 변경 목록을 확인해 주세요.");
    }
  
    return lines.join("\n");
  }
  
  async function maybePostPrSummary(force = false) {
    const metadata = await loadMetadata();
    if (!force && metadata.summaryPosted) {
      return false;
    }
  
    const summaryText = await buildPrSummaryText();
    await postThreadMessage(summaryText);
    await updateMetadata((draft) => {
      draft.summaryPosted = true;
      draft.summaryPostedAt = nowIso();
      return draft;
    });
    return true;
  }
  
  async function maybeRequestAiReview(triggerLabel) {
    const metadata = await loadMetadata();
    if (metadata.aiReviewRequested) {
      return false;
    }
  
    const requestStatus = await requestAiReviewerIfConfigured();
    const prLink = `<${pr.html_url}|#${pr.number} ${pr.title}>`;
  
    await postThreadMessage(
      [
        "*AI 리뷰 요청 활성화*",
        `*트리거* ${triggerLabel}`,
        `*상태* ${requestStatus.label}`,
        `*PR* ${prLink}`,
      ].join("\n")
    );
  
    await updateMetadata((draft) => {
      draft.aiReviewRequested = {
        trigger: triggerLabel,
        status: requestStatus.status,
        at: nowIso(),
      };
      return draft;
    });
    return true;
  }

  async function maybeNotifyReviewRequest(requestedReviewerLogins, requestedTeamSlugs) {
    const reviewerLogins = uniqueSortedStrings(requestedReviewerLogins || []);
    const teamSlugs = uniqueSortedStrings(requestedTeamSlugs || []);
    if (!reviewerLogins.length && !teamSlugs.length) {
      core.info("No requested reviewers/teams to notify.");
      return false;
    }

    const userMap = parseUserMap();
    const { mentions, unmapped } = resolveSlackMentionsFromGitHubLogins(
      userMap,
      reviewerLogins
    );

    const notifiedKey = buildReviewRequestNotifiedKey(reviewerLogins, teamSlugs);
    const shouldNotify = await markReviewRequestNotified(notifiedKey);
    if (!shouldNotify) {
      core.info("Review request notification already sent for identical targets.");
      return false;
    }

    const targetSegments = [];
    if (!mentions.length && reviewerLogins.length) {
      targetSegments.push(`리뷰어: ${reviewerLogins.join(", ")}`);
    }
    if (teamSlugs.length) {
      targetSegments.push(`팀: ${teamSlugs.map((slug) => `@${slug}`).join(", ")}`);
    }
    const targetText = targetSegments.length
      ? targetSegments.join(" / ")
      : mentions.length
        ? "멘션으로 전달"
        : "리뷰어 정보 없음(payload 확인 필요)";

    const messageLines = ["*리뷰 요청*", `*대상* ${targetText}`];
    if (mentions.length) {
      messageLines.push(mentions.join(" "));
    }

    const filteredUnmapped = unmapped.filter((login) => !isCopilotReviewer(login));
    if (filteredUnmapped.length) {
      messageLines.push(`*멘션 매핑 없음* ${filteredUnmapped.join(", ")} (SLACK_USER_MAP_JSON 확인)`);
    }

    if (!notifiedKey) {
      messageLines.push("*참고* 요청 대상이 비어 marker 저장을 건너뜀");
    }

    messageLines.push(`*PR* ${prLink}`);
    await postThreadMessage(messageLines.join("\n"));
    return true;
  }
  
  const prLink = `<${pr.html_url}|#${pr.number} ${pr.title}>`;
  await loadMetadata();
  if (metadataCommentCache && metadataCommentFormatNeedsUpgrade) {
    await updateMetadata((draft) => draft);
  }
  
  if (eventName === "issue_comment" && action === "created") {
    const comment = context.payload.comment;
    if (!comment || !isAiReviewCommandComment(comment.body)) {
      core.info("Issue comment is not an AI review command.");
      return;
    }
  
    const authorAssociation = comment.author_association || "NONE";
    const allowedAssociations = new Set(["OWNER", "MEMBER", "COLLABORATOR"]);
    if (!allowedAssociations.has(authorAssociation)) {
      core.info(`Ignoring /ai-review from non-trusted association: ${authorAssociation}`);
      return;
    }
  
    await maybeRequestAiReview("PR 코멘트 /ai-review");
    return;
  }
  
  if (eventName === "pull_request") {
    if (action === "opened") {
      await ensureThreadTs();
      await maybeNotifyReviewRequest(
        (pr.requested_reviewers || []).map((user) => user?.login).filter(Boolean),
        (pr.requested_teams || []).map((team) => team?.slug).filter(Boolean)
      );
      if (isAiReviewRequestedFromPrBody(pr.body)) {
        await maybeRequestAiReview("PR 본문 [ai-review]");
      }
      return;
    }
  
    if (action === "reopened") {
      await postThreadMessage(`🔄 PR 다시 열림: ${prLink}`);
      return;
    }
  
    if (action === "ready_for_review") {
      await postThreadMessage(`🚀 PR이 리뷰 가능 상태로 변경됨: ${prLink}`);
      await maybeNotifyReviewRequest(
        (pr.requested_reviewers || []).map((user) => user?.login).filter(Boolean),
        (pr.requested_teams || []).map((team) => team?.slug).filter(Boolean)
      );
      return;
    }
  
    if (action === "review_requested") {
      const requestedReviewerLogins = uniqueSortedStrings([
        ...(pr.requested_reviewers || []).map((user) => user?.login).filter(Boolean),
        context.payload.requested_reviewer?.login,
      ]);
      const requestedTeamSlugs = uniqueSortedStrings([
        ...(pr.requested_teams || []).map((team) => team?.slug).filter(Boolean),
        context.payload.requested_team?.slug,
      ]);
      await maybeNotifyReviewRequest(requestedReviewerLogins, requestedTeamSlugs);
  
      if (isAiReviewRequestedFromPrBody(pr.body)) {
        await maybeRequestAiReview("PR 본문 [ai-review]");
      }
      return;
    }
  
    if (action === "edited" || action === "synchronize") {
      if (isAiReviewRequestedFromPrBody(pr.body)) {
        await maybeRequestAiReview("PR 본문 [ai-review]");
      }
      return;
    }
  
    if (action === "closed") {
      if (pr.merged) {
        await postThreadMessage(`✅ PR 머지 완료: ${prLink}`);
      } else {
        await postThreadMessage(`📪 PR 닫힘(미머지): ${prLink}`);
      }
      return;
    }
  
    core.info(`Unhandled pull_request action: ${action}`);
    return;
  }
  
  if (eventName === "pull_request_review" && action === "submitted") {
    const review = context.payload.review;
    const reviewerLogin = review?.user?.login || "unknown";
    const state = reviewStateLabel(review?.state);
    const reviewHtmlUrl = review?.html_url || pr.html_url;
  
    if (isCopilotReviewer(reviewerLogin)) {
      const metadata = await loadMetadata();
      const alreadyNotifiedCopilot = (metadata.aiReviewCompletedKeys || []).some((key) =>
        String(key || "").toLowerCase().startsWith("copilot:")
      );
      if (alreadyNotifiedCopilot) {
        core.info("Copilot review notification already sent once for this PR.");
        return;
      }

      const reviewId = review?.id || "unknown";
      const shouldNotify = await markAiReviewCompleted("copilot", reviewId);
      if (!shouldNotify) {
        core.info(`Copilot review already notified: ${reviewId}`);
        return;
      }

      const reviewBody = await resolveReviewBody(review);
      const copilotOverviewLines = extractCopilotOverviewLines(reviewBody, 5);
      const messageLines = [
        "*Copilot PR 리뷰 완료*",
        `*상태* ${state}`,
        `*리뷰 링크* <${reviewHtmlUrl}|리뷰 보기>`,
      ];
      if (copilotOverviewLines.length) {
        messageLines.push("*Copilot 분석 요약*");
        messageLines.push(...copilotOverviewLines.map((line) => `- ${line}`));
      }
      messageLines.push(`*PR* ${prLink}`);
      await postThreadMessage(messageLines.join("\n"));
      return;
    }
  
    const userMap = parseUserMap();
    const prAuthorLogin = pr.user?.login || null;
    const prAuthorSlackId = findSlackUserId(userMap, prAuthorLogin);
    const mentionLine = prAuthorSlackId ? `<@${prAuthorSlackId}>\n` : "";

    const reviewState = String(review?.state || "").toLowerCase();
    if (reviewState === "approved") {
      await postThreadMessage(`${mentionLine}✅ 리뷰 완료(승인): ${prLink}`);
      return;
    }

    const statusIcon = reviewState === "changes_requested" ? "🛠️" : "👀";
    await postThreadMessage(
      `${mentionLine}${statusIcon} \`${reviewerLogin}\`님이 리뷰를 남김: *${state}*\n${prLink}`
    );
    return;
  }
  
  core.info(`Unhandled event/action: ${eventName}/${action}`);

};
