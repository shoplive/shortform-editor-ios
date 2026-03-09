#!/bin/bash

WORKING_DIR=$(pwd)

# ============================================
# 버전 업데이트 함수
# ============================================
update_version_files() {
    local VERSION=$1

    echo "🔄 버전 파일 업데이트 중..."

    XCCONFIG_FILE="XCConfigs/version.xcconfig"
    if [ -f "$XCCONFIG_FILE" ]; then
        echo "  📝 $XCCONFIG_FILE 업데이트 중..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^SL_APP_MARKETING_VERSION = .*/SL_APP_MARKETING_VERSION = $VERSION/" "$XCCONFIG_FILE"
            sed -i '' "s/^SL_STUDIO_APP_MARKETING_VERSION = .*/SL_STUDIO_APP_MARKETING_VERSION = $VERSION/" "$XCCONFIG_FILE"
        else
            sed -i "s/^SL_APP_MARKETING_VERSION = .*/SL_APP_MARKETING_VERSION = $VERSION/" "$XCCONFIG_FILE"
            sed -i "s/^SL_STUDIO_APP_MARKETING_VERSION = .*/SL_STUDIO_APP_MARKETING_VERSION = $VERSION/" "$XCCONFIG_FILE"
        fi
        echo "  ✅ $XCCONFIG_FILE 업데이트 완료"
    else
        echo "  ⚠️  경고: $XCCONFIG_FILE를 찾을 수 없습니다."
        exit 1
    fi

    SWIFT_FILE="Modules/Common/Sources/ShopliveSDKCommon.swift"
    if [ -f "$SWIFT_FILE" ]; then
        echo "  📝 $SWIFT_FILE 업데이트 중..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' -E 's/return "[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?"/return "'"$VERSION"'"/g' "$SWIFT_FILE"
        else
            sed -i -E 's/return "[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?"/return "'"$VERSION"'"/g' "$SWIFT_FILE"
        fi
        echo "  ✅ $SWIFT_FILE 업데이트 완료"
    else
        echo "  ⚠️  경고: $SWIFT_FILE를 찾을 수 없습니다."
        exit 1
    fi

    echo "✅ 모든 버전 파일 업데이트 완료!"
    echo ""
}

# ============================================
# 버전 검증 함수
# ============================================
validate_version_consistency() {
    local EXPECTED_VERSION=$1

    if [ -z "$EXPECTED_VERSION" ]; then
        echo "❌ 검증할 버전이 제공되지 않았습니다."
        exit 1
    fi

    echo "🔍 버전 일치성 검사 시작..."

    SWIFT_FILE="Modules/Common/Sources/ShopliveSDKCommon.swift"
    if [ ! -f "$SWIFT_FILE" ]; then
        echo "❌ Swift 파일을 찾을 수 없습니다: $SWIFT_FILE"
        exit 1
    fi

    SWIFT_VERSION=$(grep -m1 'return "' "$SWIFT_FILE" | sed 's/.*return "\([^"]*\)".*/\1/')
    if [ -z "$SWIFT_VERSION" ]; then
        echo "❌ Swift 파일에서 버전을 찾을 수 없습니다."
        exit 1
    fi

    echo "📋 예상 버전: $EXPECTED_VERSION"
    echo "📋 Swift 파일 버전: $SWIFT_VERSION"

    if [ "$EXPECTED_VERSION" != "$SWIFT_VERSION" ]; then
        echo ""
        echo "❌ 버전 불일치 발견!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 예상 버전: $EXPECTED_VERSION"
        echo "📄 Swift 파일: $SWIFT_VERSION"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exit 1
    fi

    echo "✅ 버전 일치성 검사 통과!"
    echo "🎯 빌드할 버전: $EXPECTED_VERSION"
    echo ""
}

# ============================================
# tuist clean / install / generate
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Tuist 프로젝트 초기화"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🧹 tuist clean 실행 중..."
tuist clean
if [ $? -ne 0 ]; then
  echo "❌ tuist clean 실패"
  exit 1
fi

echo "📦 tuist install 실행 중..."
tuist install
if [ $? -ne 0 ]; then
  echo "❌ tuist install 실패"
  exit 1
fi

echo "🔧 tuist generate 실행 중..."
tuist generate
if [ $? -ne 0 ]; then
  echo "❌ tuist generate 실패"
  exit 1
fi

echo "✅ Tuist 초기화 완료!"
echo ""

# ============================================
# 배포 버전 선택
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 배포 버전 선택"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CURRENT_TAG=$(git tag -l | grep -v '^ebay' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)

if [ -z "$CURRENT_TAG" ]; then
  echo "❌ 기존 태그를 찾을 수 없습니다."
  exit 1
fi

echo "🏷️  현재 최신 버전: $CURRENT_TAG"
echo ""

IFS='.' read -r V1 V2 V3 V4 <<< "$CURRENT_TAG"

OPTION_RELEASE="${V1}.${V2}.$((V3 + 1))"

if [ -n "$V4" ]; then
  OPTION_HOTFIX="${V1}.${V2}.${V3}.$((V4 + 1))"
else
  OPTION_HOTFIX="${V1}.${V2}.${V3}.1"
fi

echo "배포 유형을 선택해주세요:"
echo "  1) 일반 배포  → $OPTION_RELEASE"
echo "  2) 핫픽스     → $OPTION_HOTFIX"
echo "  3) 직접 입력"
echo ""
read -r VERSION_CHOICE
VERSION_CHOICE=$(echo "$VERSION_CHOICE" | xargs)

case "$VERSION_CHOICE" in
  1)
    DEPLOY_VERSION="$OPTION_RELEASE"
    ;;
  2)
    DEPLOY_VERSION="$OPTION_HOTFIX"
    ;;
  3)
    echo "배포할 버전을 입력해주세요. (예: 1.8.0 또는 1.8.0.1)"
    read -r DEPLOY_VERSION
    DEPLOY_VERSION=$(echo "$DEPLOY_VERSION" | xargs)
    if [ -z "$DEPLOY_VERSION" ]; then
      echo "❌ 버전이 입력되지 않았습니다."
      exit 1
    fi
    ;;
  *)
    echo "❌ 잘못된 선택입니다. (1, 2, 3 중 하나를 입력해주세요.)"
    exit 1
    ;;
esac

echo ""
echo "📋 선택된 배포 버전: $DEPLOY_VERSION"

if ! [[ "$DEPLOY_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "❌ 잘못된 버전 형식입니다. (예: 1.8.0 또는 1.8.0.1)"
  exit 1
fi

echo ""

# 버전 파일 업데이트
update_version_files "$DEPLOY_VERSION"

TAG_VERSION="$DEPLOY_VERSION"
LATEST_TAG="$DEPLOY_VERSION"

# 버전 검증
validate_version_consistency "$DEPLOY_VERSION"

# ============================================
# Git 커밋 및 태그 생성
# ============================================
echo "📝 Git 커밋 중..."
if [ -n "$(git status --porcelain)" ]; then
  echo "  📋 변경사항 발견, 커밋 진행..."
  git add .
  if [ $? -ne 0 ]; then
    echo "  ❌ git add 실패"
    exit 1
  fi

  COMMIT_MESSAGE="version $DEPLOY_VERSION"
  git commit -m "$COMMIT_MESSAGE"
  if [ $? -eq 0 ]; then
    echo "  ✅ 커밋 완료: $COMMIT_MESSAGE"
  else
    echo "  ❌ 커밋 실패"
    exit 1
  fi
else
  echo "  ℹ️  변경사항이 없어 커밋을 건너뜁니다."
fi

echo ""
echo "🏷️  Git 태그 생성 중..."
if git rev-parse "$LATEST_TAG" >/dev/null 2>&1; then
  echo "  ⚠️  태그가 이미 존재합니다: $LATEST_TAG"
  echo "  💡 기존 태그를 사용합니다."
else
  echo "  📝 새 태그 생성: $LATEST_TAG"
  git tag "$LATEST_TAG"
  if [ $? -eq 0 ]; then
    echo "  ✅ 태그 생성 완료: $LATEST_TAG"
  else
    echo "  ❌ 태그 생성 실패"
    exit 1
  fi
fi

echo ""
echo "✅ 버전 업데이트, 커밋 및 태그 생성 완료!"
echo "🎯 버전: $TAG_VERSION"
echo "🏷️  태그: $LATEST_TAG"
echo ""

# ============================================
# Git 커밋 및 태그 푸시
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 Git 커밋 및 태그 푸시"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REMOTE_NAME=$(git remote | grep -x "origin" || git remote | head -n1)
if [ -z "$REMOTE_NAME" ]; then
  echo "⚠️  원격 저장소를 찾을 수 없습니다. 푸시를 건너뜁니다."
else
  REMOTE_COMMIT_EXISTS=false
  CURRENT_COMMIT_HASH=$(git rev-parse HEAD)

  if ! git fetch "$REMOTE_NAME" --quiet 2>&1; then
    echo "  ⚠️  원격 저장소 정보 가져오기 실패"
  fi
  REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)

  if [ -n "$REMOTE_BRANCH" ]; then
    if git branch -r --contains "$CURRENT_COMMIT_HASH" | grep -q "$REMOTE_BRANCH"; then
      REMOTE_COMMIT_EXISTS=true
    fi
  fi

  REMOTE_TAG_EXISTS=false
  if git ls-remote --tags "$REMOTE_NAME" "$LATEST_TAG" | grep -q "$LATEST_TAG"; then
    REMOTE_TAG_EXISTS=true
  fi

  if [ "$REMOTE_COMMIT_EXISTS" = true ] || [ "$REMOTE_TAG_EXISTS" = true ]; then
    echo "⚠️  이미 원격에 같은 버전의 커밋 또는 태그가 존재합니다."
    if [ "$REMOTE_COMMIT_EXISTS" = true ]; then
      echo "  📋 현재 커밋이 원격에 이미 존재합니다."
    fi
    if [ "$REMOTE_TAG_EXISTS" = true ]; then
      echo "  🏷️  태그 '$LATEST_TAG'가 원격에 이미 존재합니다."
    fi
    echo "  💡 푸시를 건너뜁니다."
  else
    echo "📤 커밋 및 태그 푸시 중..."

    echo "  📝 커밋 푸시 중..."
    git push "$REMOTE_NAME" HEAD
    if [ $? -eq 0 ]; then
      echo "  ✅ 커밋 푸시 완료"
    else
      echo "  ❌ 커밋 푸시 실패"
      exit 1
    fi

    echo "  🏷️  태그 푸시 중..."
    git push "$REMOTE_NAME" "$LATEST_TAG"
    if [ $? -eq 0 ]; then
      echo "  ✅ 태그 푸시 완료: $LATEST_TAG"
    else
      echo "  ❌ 태그 푸시 실패"
      exit 1
    fi

    echo ""
    echo "✅ 모든 푸시가 완료되었습니다!"
  fi
fi

echo ""
echo "🎉 테스트 완료! (빌드/Pod 제외)"
echo "🏷️  버전: ${TAG_VERSION}"
echo ""
