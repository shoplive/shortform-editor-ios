// noinspection ES6ConvertVarToLetConst

(function () {
  var debugConsoleLayer;
  var isShowDebugConsole = true;
  var SHOPLIVE_CONFIG_ENDPOINT = "https://config.shoplive.cloud";

  var _accessKey, _campaignKey, _token, _options, _el, _playerIframe, _bodyBackgroundColor;

  var handleResizeEventTimer;

  var disableResizeEvent = false;

  // player가 초기화 되었는지 체크
  // 초기화 되기전에 호출된 send 이벤트를 임시로 저장
  var _playerInitialized = false;
  var _sendPlayerEventQueue = [];
  var _appInterface = "ShopLiveAppInterface";
  var _initElWidth;
  var _ua;

  function init(accessKey, campaignKey, token, options = {}) {
    _playerInitialized = false;
    _sendPlayerEventQueue = [];
    _ua = window.navigator.userAgent.toLowerCase();

    if (accessKey === "6mnefY1z9lK0vZlsduRp" && options.applicationName !== "shoplive-sdk-sample") {
      _appInterface = "MusinsaAppInterface1";
    }

    if (token == null) {
      token = "";
    } else if (typeof token === "object") {
      if (Object.keys(token).length === 0) {
        token = "";
      } else if (!token.userId) {
        throw new Error("ERROR: userId is not found in authorization parameter");
      }
    }

    (_accessKey = accessKey),
      (_campaignKey = campaignKey),
      (_token = typeof token === "string" ? token : JSON.stringify(token)),
      (_options = options);
  }

  // shoplive app에서 호출했는지 확인
  // shoplive/{version}
  function isApp() {
    return isIosApp() || isAndroidApp();
  }

  function isIosApp() {
    // noinspection JSUnresolvedVariable
    return window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers[_appInterface];
  }

  function isAndroidApp() {
    return window[_appInterface];
  }

  function initRenderOptions(options, el) {
    var isFullScreen = false;
    if (options.isFullScreen === true) {
      // 옵션이 있다면
      isFullScreen = true;
    } else if (typeof options.isFullScreen === "undefined" && el.parentElement.nodeName === "BODY") {
      // 옵션이 없다면 (auto) body 바로 밑에 있는 dom인지 체크
      isFullScreen = true;
    }

    var isContainSize = false;
    if (options.isContainSize === true || options.keepAspectOnTabletPortrait === true) {
      // 옵션이 있다면
      isContainSize = true;

      var isiPad = _ua.indexOf("ipad") > -1 || (_ua.indexOf("macintosh") > -1 && "ontouchend" in document);

      var isTablet = false;
      if ((el.clientWidth >= 768 && el.clientWidth <= 1024) || (_ua.indexOf("android") > -1 && _ua.indexOf("mobile") < 0)) {
        // FIXME
        isTablet = true;
      }
      if (isiPad || isTablet) {
        isFullScreen = false;
      }
    }

    var hasNoAddressBar = options.hasNoAddressBar;
    var hasSeekBar = true;

    var platform = "web";
    var isAndroidNative = isAndroidApp();
    var isIosNative = isIosApp();

    if (isAndroidNative || isIosNative) {
      hasNoAddressBar = true;
      if (_accessKey === "9VfTeSqTyYjNtPAMmM9Y") {
        // kolon
        hasSeekBar = false;
      }

      platform = isAndroidNative ? "Android-Native" : "iOS-Native";
    }

    var isPlayVideo = true;
    if (options.isPlayVideo === false) {
      isPlayVideo = false;
    }

    var useExtendedLayout = false;
    if (options.useExtendedLayout === true) {
      useExtendedLayout = true;
    }

    var isContainerFit = options.isContainerFit;

    return {
      isFullScreen: isFullScreen,
      isContainSize: isContainSize,
      hasNoAddressBar: hasNoAddressBar,
      useExtendedLayout: useExtendedLayout,
      hasSeekBar: hasSeekBar,
      isPlayVideo: isPlayVideo,
      platform: platform,
      isContainerFit: isContainerFit,
    };
  }

  // IE이거나 WebSocket을 지원하지 않는 경우
  function renderUnsupport(el, renderOptions) {
    // 설정 불러오기
    var request;
    if (window.XMLHttpRequest) {
      request = new XMLHttpRequest();
    } else if (window.ActiveXObject) {
      request = new ActiveXObject("Microsoft.XMLHTTP");
    }

    request.open("GET", SHOPLIVE_CONFIG_ENDPOINT + "/" + _accessKey + "/" + _campaignKey + ".json?_t=" + Math.random(), true);
    request.onreadystatechange = function () {
      if (request.readyState === 4) {
        var defaultImage = "https://static.shoplive.cloud/example/poster-ie.png";
        if (request.response) {
          var res = JSON.parse(request.response);
          defaultImage = res.unsupportInfoUrl;
        }
        var renderSize = getSize(el, renderOptions);
        var unsupportImage = document.createElement("img");
        unsupportImage.src = defaultImage;
        // unsupportImage.style.width = renderSize.w;
        unsupportImage.style.height = renderSize.h;
        unsupportImage.style.margin = "0 auto";

        el.appendChild(unsupportImage);
      }
    };
    request.send(null);
  }

  /**
   * 모드
   * - isFullScreen: 영상을 크롭하고 화면에 꽉차게 표현함
   *   - body 바로 밑에 있을 경우에 자동으로 fullscreen 선택
   * - hasNoAddressBar (앱처럼 상단에 addressbar가 없을 경우 100vh 사용)
   * - isContainSize 영상 잘리지 않으면서 꽉차게
   * @param el
   * @param renderOptions
   * @see video.js
   */
  function getSize(el, renderOptions) {
    var iframeWidth, iframeHeight;

    /**
     * 가로 모드일때 isContainSize true
     * initialize, resize 이벤트 등 공통적으로 getSize 함수를 사용하고 있어서 요기서 가로, 세로 모드 분기 추가함.
     */
    var isFullScreen = isLandscapeMode() ? false : renderOptions.isFullScreen;
    var isContainSize = isLandscapeMode() ? true : renderOptions.isContainSize;

    if (isFullScreen) {
      if (renderOptions.hasNoAddressBar) {
        iframeWidth = "100vw";
        iframeHeight = "100vh";
      } else {
        var win = window,
          doc = document,
          docElem = doc.documentElement,
          body = doc.getElementsByTagName("body")[0],
          w = win.innerWidth || docElem.clientWidth || body.clientWidth,
          h = win.innerHeight || docElem.clientHeight || body.clientHeight;
        iframeWidth = w + "px";
        iframeHeight = h + "px";
      }
    } else if (isContainSize) {
      var elWidth = document.body.offsetWidth;
      var elHeight = document.body.offsetHeight;
      if (elWidth / elHeight > 9 / 16) {
        iframeHeight = elHeight;
        iframeWidth = (elHeight * 9) / 16 + "px";
        iframeHeight += "px";
      } else {
        iframeWidth = elWidth;
        iframeHeight = (iframeWidth * 16) / 9 + "px";
        iframeWidth += "px";
      }
    } else {
      var elWidth = el.clientWidth;
      iframeWidth = elWidth;
      iframeHeight = (iframeWidth * 16) / 9 + "px";
      iframeWidth += "px";
    }

    return { w: iframeWidth, h: iframeHeight };
  }

  function initSize(target, renderOptions) {
    var playerSize = getSize(target, renderOptions);
    _el.style.position = "relative";
    _el.style.width = playerSize.w;
    _el.style.height = playerSize.h;
    _el.style.border = 0;
    _el.style.padding = 0;
    _el.style.overflow = "hidden";
    _el.style.zIndex = 1;

    if (isLandscapeMode()) {
      _el.style.margin = "0 auto";
    }
    if (renderOptions.isFullScreen || renderOptions.isContainSize) {
      _el.style.borderRadius = 0;
      _el.style.inset = 0;

      if (!renderOptions.isFullScreen && renderOptions.isContainSize) {
        _el.style.margin = "0 auto";
      }
      document.body.style.overflow = "hidden";
      document.body.style.margin = 0;
      document.body.style.padding = 0;
      if (document.documentElement) {
        document.documentElement.style.margin = 0;
        document.documentElement.style.padding = 0;
      }
    }

    if (
      _accessKey === "6mnefY1z9lK0vZlsduRp" &&
      renderOptions.isContainSize &&
      (_ua.indexOf("android") > -1 ||
        (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers["MusinsaAppInterface"]))
    ) {
      _initElWidth = playerSize.w;
      _el.style.minWidth = _initElWidth;
    }
  }

  function initIframeStyle(iframe, renderOptions) {
    iframe.style.position = "absolute";
    iframe.style.border = 0;
    iframe.style.padding = 0;
    iframe.style.overflow = "hidden";
    iframe.style.top = 0;
    iframe.style.left = 0;
    iframe.style.width = "100%";
    iframe.style.height = "100%";
    if (renderOptions.isFullScreen || renderOptions.isContainSize) {
      iframe.style.borderRadius = 0;
      iframe.style.inset = 0;
    }
  }

  // 플레이어 렌더링
  function renderPlayer(el, accessKey, campaignKey, token, options, renderOptions, isPlayVideo) {
    var iframe = document.createElement("iframe");
    var playerHtml = "player.html";
    var src =
      playerHtml +
      "?ak=" +
      accessKey +
      "&ck=" +
      campaignKey +
      "&tk=" +
      encodeURIComponent(token) +
      "&rf=" +
      encodeURIComponent(document.referrer);

    if (options.ui) {
      src += "&ui=" + encodeURIComponent(JSON.stringify(options.ui));
    }
    if (options.brand) {
      src += "&brand=" + encodeURIComponent(JSON.stringify(options.brand));
    }
    if (options.version) {
      src += "&version=" + options.version;
    }
    if (options.masking) {
      src += "&masking=1";
    }
    if (options.hideControls) {
      src += "&hideControls=1";
    }
    if (options.unmute) {
      src += "&unmute=1";
    }
    if (options.isReplay) {
      src += "&isReplay=1";
    }
    if (options.replayMode === "ORIGINAL") {
      src += "&replayMode=ORIGINAL";
    }
    if (options.replayTsContinuity !== undefined) {
      src += "&replayTsContinuity=" + options.replayTsContinuity;
    }
    if (options.replaySyncTimeCorrection) {
      src += "&replaySyncTimeCorrection=" + options.replaySyncTimeCorrection;
    }
    if (options.passcode) {
      src += "&passcode=" + options.passcode;
    }
    if (options.preview) {
      src += "&preview=1";
    }
    if (options.isListenConnectionState) {
      src += "&isListenConnectionState=1";
    }
    if (options.shareUrl) {
      src += "&shareUrl=" + encodeURIComponent(options.shareUrl);
    }
    if (options.isAdministrator) {
      src += "&isAdministrator=1";
    }
    if (renderOptions.isFullScreen) {
      src += "&isFullScreen=1";
    }
    if (renderOptions.isContainSize) {
      src += "&isContainSize=1";
    }
    if (renderOptions.useExtendedLayout) {
      src += "&useExtendedLayout=1";
    }
    if (renderOptions.hasSeekBar) {
      src += "&hasSeekBar=1";
    }
    if (renderOptions.platform) {
      src += "&platform=" + renderOptions.platform;
    }
    if (options.guestUid) {
      src += "&guestUid=" + options.guestUid;
    }
    if (options.resolution) {
      src += "&resolution=" + options.resolution;
    }
    if (options.rk) {
      src += "&rk=" + options.rk;
    }
    if (options.closePlayerAfterCampaignEnd) {
      src += "&closePlayerAfterCampaignEnd=" + options.closePlayerAfterCampaignEnd;
    }
    if (options.iOS15WarningScheme) {
      src += "&iOS15WarningScheme=" + options.iOS15WarningScheme;
    }
    if (options.iOS15WarningMessage) {
      src += "&iOS15WarningMessage=" + options.iOS15WarningMessage;
    }
    if (options.initResolution) {
      src += "&initResolution=" + options.initResolution;
    }
    if (options.forceReplaySnapshot) {
      src += "&forceReplaySnapshot=" + options.forceReplaySnapshot;
    }
    if (isPlayVideo === false) {
      src += "&isPlayVideo=false";
    }
    if (isApp()) {
      src += "&isNativeApp=true";
    }
    if (options.isUIPreview) {
      src += "&isUIPreview=" + options.isUIPreview;
    }

    if (options.chatFilterPatterns && options.chatFilterPatterns.length > 0) {
      src += "&chatFilterPatterns=" + JSON.stringify(options.chatFilterPatterns);
    }

    // 콘솔 환경에서, 권한처리 관련 옵션.
    if (options.consolePrivileges) {
      src += "&consolePrivileges=" + JSON.stringify(options.consolePrivileges);
    }

    // 이벤트타임의 현장시간 realtime 쓰는 옵션.
    if (options.realtimeEvent) {
      src += "&realtimeEvent=" + options.realtimeEvent;
    }

    //options.showCart 처리.
    if (options.showCart === false) {
      src += "&showCart=false";
    }

    if (options.adId) {
      src += "&adId=" + encodeURIComponent(options.adId);
    }

    iframe.src = src;

    // containerFit 옵션이라면, iframe 도 그냥 100%로 해준다.
    if (renderOptions.isContainerFit) {
      iframe.style.border = "none";
      iframe.style.width = "100%";
      iframe.style.height = "100%";
      iframe.style.overflow = "hidden";
      iframe.style.boxSizing = "border-box";
    }

    // containerFit 옵션이 아니라면, 기존 로직 사용.
    else {
      initIframeStyle(iframe, renderOptions);
    }

    el.appendChild(iframe);

    return iframe;
  }

  // 앱용 이벤트 추가
  function attachAppEventListener() {
    // 비디오 플레이어로 전송하는 메시지를 가로채서 앱으로 재전송
    function handleShopliveAppVideoPlayer(method, action, payload) {
      // 앱으로 보내줘야 하는 이벤트에 VIDEO: 이 붙어있다면 제거해준다.
      var videoAction = action.replace("VIDEO:", "");
      if (method === "send") {
        switch (videoAction) {
          case "setPosterUrl":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "SET_POSTER_URL",
                payload: { posterUrl: payload.value },
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].SET_POSTER_URL(payload.value);
            }
            break;
          case "setLiveStreamUrl":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "SET_LIVE_STREAM_URL",
                payload: { liveStreamUrl: payload.value },
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].SET_LIVE_STREAM_URL(payload.value);
            }
            break;
          case "setVideoMute":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "SET_VIDEO_MUTE",
                payload: { isMuted: payload.value },
              });
            }
            try {
              if (isAndroidApp()) {
                window[_appInterface].SET_VIDEO_MUTE(payload.value);
              }
            } catch (error) {
              console.error(error);
            }

            break;
          case "setIsPlayingVideo":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "SET_IS_PLAYING_VIDEO",
                payload: { isPlaying: payload.value },
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].SET_IS_PLAYING_VIDEO(payload.value);
            }
            break;

          case "playVideo":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "SET_IS_PLAYING_VIDEO",
                payload: { isPlaying: true },
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].SET_IS_PLAYING_VIDEO(true);
            }
            break;

          case "pauseVideo":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "SET_IS_PLAYING_VIDEO",
                payload: { isPlaying: false },
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].SET_IS_PLAYING_VIDEO(false);
            }
            break;

          case "reloadVideo":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "RELOAD_VIDEO",
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].RELOAD_VIDEO();
            }
            break;
          case "setIsReplay":
            var rect = _el.getBoundingClientRect();
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "REPLAY",
                payload: { width: rect.width, height: rect.height },
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].REPLAY(rect.width, rect.height);
            }
            break;

          // 리플레이 - 영상 seeking 할때 by joseph.
          case "setVideoCurrentTime":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "SET_VIDEO_CURRENT_TIME",
                payload: { value: payload.value },
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].SET_VIDEO_CURRENT_TIME(payload.value);
            }
            break;

          case "showNativeChatInput":
            if (isIosApp()) {
              window.webkit.messageHandlers[_appInterface].postMessage({
                action: "SHOW_CHAT_INPUT",
              });
            }
            if (isAndroidApp()) {
              window[_appInterface].SHOW_CHAT_INPUT();
            }
            break;
        }
      }
    }

    window[window.ShoplivePlayer + "_video"] = handleShopliveAppVideoPlayer;

    // 앱으로부터 받는 이벤트 생성
    function handleReceiveAppEvent(action, payload) {
      switch (action) {
        case "VIDEO_INITIALIZED":
          window[window.ShoplivePlayer]("send", "videoPlayerInitialized", {});
          break;
        case "SET_IS_PLAYING_VIDEO":
          window[window.ShoplivePlayer]("send", "setIsPlayingVideo", {
            value: payload,
          });
          break;
        case "RELOAD_BTN":
          window[window.ShoplivePlayer]("send", "setReloadBtn", {
            value: payload,
          });
          break;
        case "DOWN_KEYBOARD": // deprecated
        case "SHOW_GOODS_UI": // deprecated
          window[window.ShoplivePlayer]("send", "setShowGoodsUi", {
            value: payload,
          });
          break;
        case "HIDDEN_CHAT_INPUT": // 앱 네이티브 키보드 내림
          window[window.ShoplivePlayer]("send", "hiddenChatInput", {
            value: payload,
          });
          break;
        case "REMOVE_COUPON":
          window[window.ShoplivePlayer]("send", "removeCoupon", {
            value: payload,
          });
          break;
        case "REMOVE_BANNER":
          window[window.ShoplivePlayer]("send", "removeBanner", {
            value: payload,
          });
          break;
        case "REMOVE_NOTICE":
          window[window.ShoplivePlayer]("send", "removeNotice", {
            value: payload,
          });
          break;
        case "COMPLETE_DOWNLOAD_COUPON":
          window[window.ShoplivePlayer]("send", "completeDownloadCoupon", {
            value: payload,
          });
          break;
        case "FAIL_DOWNLOAD_COUPON": // DEPRECATED
          window[window.ShoplivePlayer]("send", "failDownloadCoupon", payload);
          break;
        case "CUSTOM_ACTION_RESULT":
        case "DOWNLOAD_COUPON_RESULT":
          // {
          //   success: true,
          //   coupon: payload.coupon,
          //   id : payload.popupResourceId,
          //   couponStatus: "HIDE",
          //   message: "쿠폰 다운로드에 실패했습니다. 잠시 후 다시 시도해 주세요.",
          //   alertType: "TOAST",
          // }
          window[window.ShoplivePlayer]("send", "downloadCouponResult", payload);
          break;
        case "COMPLETE_CUSTOM_ACTION":
          window[window.ShoplivePlayer]("send", "completeCustomAction", {
            value: payload,
          });
          break;
        case "ON_PIP_MODE_CHANGED":
          window[window.ShoplivePlayer]("send", "setIsPipMode", {
            value: payload,
          });
          break;

        case "ON_VIDEO_TIME_UPDATED":
          window[window.ShoplivePlayer]("send", "onVideoTimeUpdated", {
            value: payload,
          });
          break;

        case "ON_VIDEO_METADATA_UPDATED":
          window[window.ShoplivePlayer]("send", "onVideoMetadataUpdated", payload);
          break;

        case "ON_VIDEO_DURATION_CHANGED":
          window[window.ShoplivePlayer]("send", "onVideoDurationChanged", {
            value: payload,
          });
          break;

        case "ON_BACKGROUND":
          window[window.ShoplivePlayer]("send", "onBackground", {});
          break;

        case "ON_FOREGROUND":
          window[window.ShoplivePlayer]("send", "onForeground", {});
          break;

        case "ON_TERMINATED":
          window[window.ShoplivePlayer]("send", "onTerminated", {});
          break;

        case "WRITE": // 채팅 전송
          window[window.ShoplivePlayer]("send", "write", payload);

          if (isIosApp()) {
            window.webkit.messageHandlers[_appInterface].postMessage({
              action: "WRITTEN",
              payload: {
                _s: 0,
              },
            });
          }
          if (isAndroidApp()) {
            window[_appInterface].WRITTEN({
              _s: 0,
            });
          }
          break;

        case "SET_PROFILE": // 이름 등 변경
          window[window.ShoplivePlayer]("send", "setProfile", payload);

          break;

        case "SET_CHAT_LIST_MARGIN_BOTTOM":
          debugLog("SET_CHAT_LIST_MARGIN_BOTTOM called with {}", payload);
          window[window.ShoplivePlayer]("send", "setChatListMarginBottom", payload);
          break;

        case "SET_VIDEO_MUTE":
          window[window.ShoplivePlayer]("send", "setVideoMute", { value: payload });
          break;

        case "SEND_COMMAND_MESSAGE":
          window[window.ShoplivePlayer]("send", "SEND_COMMAND_MESSAGE", payload);
          break;
      }
    }

    // app -> control event
    window.__receiveAppEvent = handleReceiveAppEvent;

    if (isIosApp()) {
      window.webkit.messageHandlers[_appInterface].postMessage({
        action: "SYSTEM_INIT",
      });
    }
    if (isAndroidApp()) {
      window[_appInterface].SYSTEM_INIT();
    }
  }

  // player 실행
  function run(elementId) {
    // 기본 메시지 콜백
    var defaultMessageCallback = {
      CLICK_HEADER_LOGO: function (payload) {
        if (payload.url) {
          location.href = payload.url;
        }
      },

      LINK: function (payload) {
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "NAVIGATION",
            payload: { url: payload.url },
          });
        } else if (isAndroidApp()) {
          window[_appInterface].NAVIGATION(payload.url);
        } else {
          location.href = payload.url;
        }
      },

      LINK_NEW_WINDOW: function (payload) {
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "NAVIGATION",
            payload: { url: payload.url },
          });
        } else if (isAndroidApp()) {
          window[_appInterface].NAVIGATION(payload.url);
        } else {
          window.open(payload.url);
        }
      },

      SET_USER_NAME: function (payload) {
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "SET_USER_NAME",
            payload: payload,
          });
        } else if (isAndroidApp()) {
          window[_appInterface].SET_USER_NAME(JSON.stringify(payload));
        } else {
          debugLog(`[SET_USER_NAME] : ` + JSON.stringify(payload));
        }
      },

      REQUEST_LOGIN: function (payload) {
        debugLog("Login is required : Implementation required");
      },
      UNAUTHORIZED: function (payload) {
        if (payload.code == -115) {
          // const { title,
          //  message,
          //  cancelText,
          //  confirmText,
          //  confirmTextColor,
          //  confirmBackgroundColor,
          //  confirmCallbackMessage,
          //  confirmCallbackPayload,
          //  confirmFunction,
          //  cancelFunction } = dialogData
          sendPlayerEvent("showDialog", {
            title: "로그인이 필요합니다.",
            message: "방송을 시청하기 위해서는 로그인이 필요합니다.\n로그인하시겠습니까?",
            cancelText: "취소",
            confirmText: "확인",
            confirmCallbackMessage: "REQUEST_LOGIN",
          });
        }
      },
      ERROR: function (payload) {
        debugLog(payload.code);
        debugLog(payload.msg);
      },
      DOWNLOAD_COUPON: function (payload) {
        var coupon = payload.coupon;
        debugLog(`[DOWNLOAD_COUPON '${coupon}'] Need to implement.`);
      },
      CLICK_PRODUCT: function (payload) {
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "NAVIGATION",
            payload: {
              url: payload.url,
            },
          });
        } else if (isAndroidApp()) {
          window[_appInterface].NAVIGATION(payload.url);
        } else {
          window.open(payload.url);
        }
      },
      CUSTOM_ACTION: function (data) {
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "CUSTOM_ACTION",
            payload: {
              id: data.id,
              type: data.type,
              payload: data.payload,
            },
          });
        } else if (isAndroidApp()) {
          window[_appInterface].CUSTOM_ACTION(
            JSON.stringify({
              id: data.id,
              type: data.type,
              payload: data.payload,
            })
          );
        } else {
          debugLog(`[CUSTOM_ACTION] Need to implement. {}`, typeof data == "object" ? JSON.stringify(data) : data);
        }
      },
      CLICK_SHARE_BTN: function (payload) {
        if (payload.shareUrl) {
          if (navigator.share) {
            navigator
              .share({
                title: payload.title,
                text: "",
                url: payload.shareUrl,
              })
              .catch((e) => {
                console.log(e);
              });
          } else {
            // console.log("TODO copy url and alert message : 복사되었습니다.", payload.shareUrl);
            var textarea = document.createElement("textarea");
            document.body.appendChild(textarea);
            textarea.value = payload.shareUrl;
            textarea.select();
            document.execCommand("copy");
            document.body.removeChild(textarea);
            if (navigator.language.match("ko")) {
              alert("URL이 복사되었습니다.");
            } else {
              alert("URL copied!");
            }
          }
        } else {
          debugLog("[CLICK_SHARE_BTN] Need to implement.");
        }
      },
      REQUEST_PICTURE_IN_PICTURE: function () {
        debugLog("[REQUEST_PICTURE_IN_PICTURE] called.");
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "ENTER_PIP",
          });
        } else if (isAndroidApp()) {
          window[_appInterface].ENTER_PIP();
        } else {
          debugLog("[REQUEST_PICTURE_IN_PICTURE] Need to implement.");
        }
      },
      CLOSE_PLAYER: function () {
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "CLOSE",
          });
        } else if (isAndroidApp()) {
          window[_appInterface].CLOSE();
        } else {
          history.back();
        }
      },
      START_SCROLL: function () {
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "DISABLE_SWIPE_DOWN",
          });
        } else if (isAndroidApp()) {
          window[_appInterface].DISABLE_SWIPE_DOWN();
        }
      },
      STOP_SCROLL: function () {
        if (isIosApp()) {
          window.webkit.messageHandlers[_appInterface].postMessage({
            action: "ENABLE_SWIPE_DOWN",
          });
        } else if (isAndroidApp()) {
          window[_appInterface].ENABLE_SWIPE_DOWN();
        }
      },
    };

    var options = _options;
    // if (!options.playerUrlPrefix) {
    //   options.playerUrlPrefix = "https://static.shoplive.cloud";
    // }
    options.playerUrlPrefix = "";

    function handleMessage(action, payload) {
      // 기본
      switch (action) {
        case "PLAYER_INITIALIZED":
          // console.log("PLAYER_INITIALIZED with", payload);

          _playerInitialized = true;
          for (var i = 0; i < _sendPlayerEventQueue.length; i++) {
            sendPlayerEvent(_sendPlayerEventQueue[i].action, _sendPlayerEventQueue[i].payload);
          }
          break;

        case "VIDEO_INITIALIZED":
          window[window.ShoplivePlayer]("send", "videoPlayerInitialized", {});
          break;

        case "SET_CONF":
          if (isIosApp()) {
            window.webkit.messageHandlers[_appInterface].postMessage({
              action: "SET_CONF",
              payload: payload,
            });
          } else if (isAndroidApp()) {
            window[_appInterface].SET_CONF(JSON.stringify(payload));
          }
          break;

        case "ON_CAMPAIGN_STATUS_CHANGED":
          if (isIosApp()) {
            window.webkit.messageHandlers[_appInterface].postMessage({
              action: "ON_CAMPAIGN_STATUS_CHANGED",
              payload: payload,
            });
          } else if (isAndroidApp()) {
            window[_appInterface].ON_CAMPAIGN_STATUS_CHANGED(payload.status);
          }
          break;

        case "FIX_SCROLL":
          if (renderOptions.isFullScreen) {
            window.scrollTo(0, 0);
          }
          break;

        // player
        case "SET_RELOAD_BTN":
          window[window.ShoplivePlayer]("send", "setReloadBtn", payload);
          break;

        case "SET_IS_PLAYING_VIDEO":
          window[window.ShoplivePlayer]("send", "setIsPlayingVideo", payload);
          break;

        case "ON_VIDEO_TIME_UPDATED":
          window[window.ShoplivePlayer]("send", "onVideoTimeUpdated", payload);
          break;

        case "ON_VIDEO_DURATION_CHANGED":
          window[window.ShoplivePlayer]("send", "onVideoDurationChanged", payload);
          break;

        case "SET_PARAM":
          if (isIosApp()) {
            window.webkit.messageHandlers[_appInterface].postMessage({
              action: "SET_PARAM",
              payload: payload,
            });
          }
          break;

        case "DEL_PARAM":
          if (isIosApp()) {
            window.webkit.messageHandlers[_appInterface].postMessage({
              action: "DEL_PARAM",
              payload: payload,
            });
          }
          break;

        case "SHOW_NATIVE_DEBUG":
          if (isIosApp()) {
            window.webkit.messageHandlers[_appInterface].postMessage({
              action: "SHOW_NATIVE_DEBUG",
              payload: {},
            });
          } else if (isAndroidApp()) {
            window[_appInterface].SHOW_NATIVE_DEBUG();
          }
          break;

        case "DISABLE_RESIZE_EVENT":
          disableResizeEvent = true;
          break;

        case "ENABLE_RESIZE_EVENT":
          disableResizeEvent = false;
          break;

        default:
          // 커스텀
          if (_options.messageCallback && _options.messageCallback[action]) {
            debugLog("messageCallback for {} is called {}", action, payload ? "with " + JSON.stringify(payload) : "");
            _options.messageCallback[action](payload, defaultMessageCallback[action]);
          } else if (defaultMessageCallback[action]) {
            debugLog("defaultMessageCallback", defaultMessageCallback, action, payload);
            defaultMessageCallback[action](payload);
          }

          // video
          if (action.indexOf("VIDEO:") === 0 && window[window.ShoplivePlayer + "_video"]) {
            // window[window.ShoplivePlayer + "_video"]("send", action.substring(6), payload);
            //  VIDEO: 제거하지 않고 그냥 보낸다. by Joseph, Video.svelte 안으로 넣기 작업 관련.
            window[window.ShoplivePlayer + "_video"]("send", action, payload);
          }

          break;
      }
    }

    var target = document.getElementById(elementId);
    target.innerHTML = "";
    target.style.fontSize = 0;
    target.style.lineHeight = 0;

    var agent = navigator.userAgent.toLowerCase();
    var isIE = (navigator.appName === "Netscape" && navigator.userAgent.search("Trident") !== -1) || agent.indexOf("msie") !== -1;
    var supportsWebSockets = "WebSocket" in window || "MozWebSocket" in window;

    var renderOptions = initRenderOptions(options, target);
    if (renderOptions.hasNoAddressBar) {
      target.style.width = "100vw";
      target.style.height = "100vh";
    }

    if (isIE || !supportsWebSockets) {
      renderUnsupport(target, renderOptions);
      return;
    }

    _el = document.createElement("div");
    target.appendChild(_el);

    // isContainerFit 옵션이면, 그냥 컨테이너에 맞게 100% 해줌.
    if (renderOptions.isContainerFit) {
      _el.style.border = "none";
      _el.style.width = "100%";
      _el.style.height = "100%";
      _el.style.position = "relative";
    }

    // containerFit 이 아니라며 기존 로직 그대로 사용.
    else {
      initSize(target, renderOptions);
    }

    var isPlayVideo = true;
    if (options.isPlayVideo === false) {
      isPlayVideo = false;
    } else if (isApp() && _accessKey === "9VfTeSqTyYjNtPAMmM9Y") {
      // kolon app
      isPlayVideo = false;
    }

    if (!isPlayVideo || isApp()) {
      // app은 앱전용 비디오 플레이어를 사용함
      attachAppEventListener();
      document.body.style.backgroundColor = "transparent";

      player.app = window.__receiveAppEvent;
    }

    _playerIframe = renderPlayer(_el, _accessKey, _campaignKey, _token, options, renderOptions, isPlayVideo);

    _bodyBackgroundColor = document.body.style.backgroundColor;
    // 가로모드 배경색 무신사만 예외처리
    if (!isApp() && isLandscapeMode() && _accessKey !== "6mnefY1z9lK0vZlsduRp") {
      document.body.style.backgroundColor = "#000";
    }

    // 새로 만든 ShopliveEvent 처리.
    function handleShopliveEvent(event, payload) {
      debugLog("handleShopliveEvent : " + event.name);

      if (payload) {
        debugLog("PAYLOAD -- " + JSON.stringify(payload));
      }

      // 일단 이벤트 타입이 USER_IMPLEMENTS_CALLBACK 이라면,
      if (event.metadata.type === "USER_IMPLEMENTS_CALLBACK") {
        // event.name 과 같은 이름의 콜백이 있으면 실행시켜주고 끝낸다.
        if (_options.messageCallback && _options.messageCallback[event.name]) {
          _options.messageCallback[event.name](payload, defaultMessageCallback[event.name], event);
          return;
        }
        // 앱 아니고, 웹이면서, defaultMessageCallback 에 정의되어있다면 실행해 주고 끝.
        else if (!isApp() && defaultMessageCallback[event.name]) {
          defaultMessageCallback[event.name](payload);
          return;
        }
      }

      const MusinsaAppInterfaceName = "MusinsaAppInterface";
      if (event.name === "VIBRATE") {
        // iOS 무신사 앱인경우
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers[MusinsaAppInterfaceName]) {
          try {
            window.webkit.messageHandlers[MusinsaAppInterfaceName].postMessage({
              command: "vibrate",
              name: null,
              parameters: null,
            });
          } catch (error) {
            console.error(error);
          }
        } else if (window[MusinsaAppInterfaceName]) {
          debugLog("Musinsa Android App");
          window[MusinsaAppInterfaceName].vibrate();
        }
      }

      // optiuons.messageCallback 에 defaultMessageCallback 에 없다면, SDK 로 넘겨준다.
      if (isIosApp()) {
        window.webkit.messageHandlers[_appInterface].postMessage({
          shopliveEvent: event,
          payload: payload,
        });
      } else if (isAndroidApp()) {
        window[_appInterface].onReceiveShopliveEvent(JSON.stringify(event), JSON.stringify(payload));
      }
    }

    // 플레이어 내부 이벤트 메시지 처리
    function receiveMessage(event) {
      if (!event.data || (!event.data.action && !event.data.shopliveEvent)) {
        return;
      }

      if (event.data.shopliveEvent) {
        handleShopliveEvent(event.data.shopliveEvent, event.data.payload);
      } else {
        handleMessage(event.data.action, event.data.payload);
      }
    }

    // 윈도우 리사이즈
    function handleResizeEvent() {
      updatePlayerSize(0);
    }

    function updatePlayerSize(count) {
      if (disableResizeEvent) {
        // console.log("Resize Disabled");
        return;
      }

      if (isLandscapeMode()) {
        // 가로모드 배경색 무신사만 예외처리
        if (!isApp() && _accessKey !== "6mnefY1z9lK0vZlsduRp") {
          document.body.style.backgroundColor = "#000";
        }
        _el.style.margin = "0 auto";
      } else {
        document.body.style.backgroundColor = _bodyBackgroundColor;
        _el.style.margin = 0;

        if (!renderOptions.isFullScreen && renderOptions.isContainSize) {
          _el.style.margin = "0 auto";
        }
      }
      var playerSize = getSize(target, renderOptions);
      _el.style.position = "relative";
      _el.style.width = playerSize.w;
      _el.style.height = playerSize.h;

      debugLog("handleResizeEvent {} x {}", playerSize.w, playerSize.h);

      if (count > 2) {
        return;
      }

      if (handleResizeEventTimer) {
        clearTimeout(handleResizeEventTimer);
      }

      handleResizeEventTimer = setTimeout(function () {
        updatePlayerSize(count + 1);
      }, 100 * ((count + 1) * (count + 1)));
    }

    // nextjs에서처럼 window는 그대로지만 함수는 재선언 되는 상황 방지
    if (!window.__receiveMessage) {
      window.__receiveMessage = receiveMessage;
    }

    // 두번 등록되지 않도록 제거 후 추가
    window.removeEventListener("message", window.__receiveMessage);
    window.addEventListener("message", window.__receiveMessage, false);

    // nextjs에서처럼 window는 그대로지만 함수는 재선언 되는 상황 방지
    if (!window.__handleResizeEvent) {
      window.__handleResizeEvent = handleResizeEvent;
    }

    // 두번 등록되지 않도록 제거 후 추가
    window.removeEventListener("resize", window.__handleResizeEvent);
    if (!renderOptions.isContainerFit) {
      window.addEventListener("resize", window.__handleResizeEvent, false);
    }

    if (_options.__debug) {
      appendDebug(target);
      debugLog("Player initialized with options {}", JSON.stringify(options));
    }

    // 크롬에서 간헐적으로 초기 화면 사이즈가 안맞을 때가 있어서 리사이즈 한번 시켜줌
    if (_ua.indexOf("crios") > -1 || _ua.indexOf("chrome") > -1) {
      if (!renderOptions.isContainerFit) {
        handleResizeEvent();
      }
    }
    handleMessage("SYSTEM_INIT", defaultMessageCallback["SYSTEM_INIT"]);
  }

  function appendDebug(el) {
    var div = document.createElement("div");
    div.style.position = "absolute";
    div.style.margin = "100px 3px 0 3px";
    div.style.top = "20px";
    div.style.left = "0";
    div.style.right = "0";
    div.style.backgroundColor = "rgba(0, 0, 0, 0.5)";
    div.style.color = "#ffffff";
    div.style.fontSize = "12px";
    div.style.textAlign = "left";
    div.style.lineHeight = "1.1";
    div.style.wordBreak = "break-all";
    div.style.overflow = "scroll";
    div.style.maxHeight = "250px";
    div.style.zIndex = 999;

    var button = document.createElement("button");
    button.innerText = "DEBUG ON";
    button.style.color = "#ffffff";
    button.style.textDecoration = "underline";
    button.addEventListener(
      "click",
      function () {
        if (isShowDebugConsole) {
          debugConsoleLayer.style.display = "none";
          isShowDebugConsole = false;
        } else {
          debugConsoleLayer.style.display = "block";
          isShowDebugConsole = true;
        }
      },
      false
    );

    div.appendChild(button);

    debugConsoleLayer = document.createElement("div");
    div.appendChild(debugConsoleLayer);
    el.appendChild(div);
  }

  function debugLog() {
    if (!_options.__debug) {
      return;
    }

    var format = arguments[0];
    var binds = [];
    for (var i = 1; i < arguments.length; i++) {
      binds.push(arguments[i]);
    }
    if (!format) {
      return;
    }

    var m = "";
    if (binds && binds.length > 0) {
      var pos = 0,
        nth = 0,
        len = format.length;
      for (; pos < len; pos++) {
        if (nth < arguments.length && format[pos] === "{" && pos < len - 1 && format[pos + 1] === "}") {
          m += binds[nth++];
          pos++;
        } else {
          m += format[pos];
        }
      }

      for (; pos < len; pos++) {
        m += binds[pos];
      }
    } else {
      m = format;
    }

    debugConsoleLayer.innerHTML += "[" + new Date().toLocaleTimeString() + "] " + m + "<br />";

    debugConsoleLayer.scrollIntoView(false);
  }

  function sendPlayerEvent(sendAction, _sendPayload) {
    if (!_playerIframe) {
      return;
    }

    var sendPayload = _sendPayload || {};

    if (_playerInitialized) {
      _playerIframe.contentWindow.postMessage({ action: sendAction, payload: sendPayload }, "*");
    } else {
      _sendPlayerEventQueue.push({ action: sendAction, payload: sendPayload });
    }
  }

  // 가로 모드인지 체크
  function isLandscapeMode() {
    var orientation = window.orientation;
    if (orientation !== undefined) {
      if (orientation === 90 || orientation === -90) {
        return true;
      }
    }
    return false;
  }

  // 방송 클라이언트 초기화
  var player = window[window.ShoplivePlayer];
  player.q = player.q || [];
  player.init = player.init || init;
  player.run = player.run || run;
  player.send = player.send || sendPlayerEvent;
  window[window.ShoplivePlayer + "_video"] =
    window[window.ShoplivePlayer + "_video"] ||
    function handleShopliveVideoPlayer(method, action, payload) {
      if (method === "send") {
        sendPlayerEvent(action, payload);
      }
    };

  while (player.q.length) {
    var args = player.q.shift();
    if (args.length) {
      var k = [].slice.call(args);
      player[k[0]].apply(null, k.slice(1));
    }
  }

  player.q.push = function () {
    var args = arguments[0];
    if (args.length) {
      var k = [].slice.call(args);
      player[k[0]].apply(null, k.slice(1));
    }
  };
})();
