// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum ShopLivePlayerDemoStrings {

  public enum Alert {

    public enum Login {

      public enum Required {
      /// 로그인이 필요합니다. 로그인 화면으로 \n 이동하시겠습니까?
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "alert.login.required.description")
      }
    }

    public enum Msg {
    /// 취소
      public static let cancel = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.cancel")
      /// 확인
      public static let confirm = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.confirm")
      /// 삭제
      public static let delete = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.delete")
      /// 실패
      public static let failed = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.failed")
      /// 아니오
      public static let no = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.no")
      /// 예
      public static let ok = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.ok")
      /// 저장
      public static let save = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.save")
      /// 성공
      public static let success = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.success")
    }
  }

  public enum Appversion {

    public enum Alert {
    /// 예) 1.0.0
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "appversion.alert.placeholder")
    }
  }

  public enum Base {

    public enum Section {

      public enum CampaignInfo {
      /// 방송정보
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.campaignInfo.title")

        public enum Campaign {

          public enum None {
          /// 선택된 방송이 없습니다.
            public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.campaignInfo.campaign.none.title")
          }
        }
      }

      public enum CampaignInof {

        public enum Button {

          public enum ChooseCampaign {
          /// 방송 선택
            public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.campaignInof.button.chooseCampaign.title")
          }
        }
      }

      public enum Userinfo {
      /// 유저정보
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.userinfo.title")

        public enum Button {

          public enum ChooseCampaign {

            public enum Change {
            /// 변경
              public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.userinfo.button.chooseCampaign.change.title")
            }

            public enum Input {
            /// 입력
              public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.userinfo.button.chooseCampaign.input.title")
            }
          }
        }

        public enum None {
        /// 유저 정보를 입력해 보세요.
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.userinfo.none.title")
        }
      }
    }
  }

  public enum Campaign {

    public enum Input {

      public enum Accesskey {
      /// accessKey
        public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.input.accesskey.placeholder")
      }

      public enum Campaignkey {
      /// campaignKey
        public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.input.campaignkey.placeholder")
      }
    }

    public enum Menu {
    /// 전체삭제
      public static let deleteall = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.menu.deleteall")
      /// 직접 입력
      public static let write = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.menu.write")
    }

    public enum Msg {
    /// 잘못된 url 입니다.
      public static let wrongurl = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.msg.wrongurl")

      public enum DeleteAll {
      /// 캠페인을 모두 삭제 하시겠습니까?
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.msg.deleteAll.title")
      }
    }
  }

  public enum Couponresponse {

    public enum Failed {
    /// 쿠폰 다운로드에 실패 했습니다.
      public static let `default` = ShopLivePlayerDemoStrings.tr("shoplive", "couponresponse.failed.default")
      /// * Setting Action for Failed
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "couponresponse.failed.title")
    }

    public enum Msg {
    /// Alert Setting
      public static let alert = ShopLivePlayerDemoStrings.tr("shoplive", "couponresponse.msg.alert")
      /// Message
      public static let message = ShopLivePlayerDemoStrings.tr("shoplive", "couponresponse.msg.message")
      /// Show Coupon
      public static let show = ShopLivePlayerDemoStrings.tr("shoplive", "couponresponse.msg.show")
    }

    public enum Success {
    /// 쿠폰 다운로드에 성공 했습니다.
      public static let `default` = ShopLivePlayerDemoStrings.tr("shoplive", "couponresponse.success.default")
      /// * Setting Action for Success
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "couponresponse.success.title")
    }
  }

  public enum Guide {
  /// Use custom share
    public static let customShare = ShopLivePlayerDemoStrings.tr("shoplive", "guide.customShare")
  }

  public enum Login {

    public enum Id {
    /// User ID
      public static let label = ShopLivePlayerDemoStrings.tr("shoplive", "login.id.label")
      /// Enter User ID
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "login.id.placeholder")
    }

    public enum Pwd {
    /// Password
      public static let label = ShopLivePlayerDemoStrings.tr("shoplive", "login.pwd.label")
      /// Enter Password
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "login.pwd.placeholder")
    }

    public enum Send {
    /// Log In
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "login.send.title")
    }
  }

  public enum Menu {
  /// 방송 목록 관리
    public static let campaigns = ShopLivePlayerDemoStrings.tr("shoplive", "menu.campaigns")
    /// 쿠폰 응답 설정
    public static let coupon = ShopLivePlayerDemoStrings.tr("shoplive", "menu.coupon")
    /// 방송 나가기(PIP 종료)
    public static let exit = ShopLivePlayerDemoStrings.tr("shoplive", "menu.exit")
    /// 옵션 설정
    public static let options = ShopLivePlayerDemoStrings.tr("shoplive", "menu.options")
    /// 웹 스토리지 데이터 삭제
    public static let removeCache = ShopLivePlayerDemoStrings.tr("shoplive", "menu.removeCache")
    /// 유저 정보 입력
    public static let userinfo = ShopLivePlayerDemoStrings.tr("shoplive", "menu.userinfo")

    public enum Msg {
    /// 웹 스토리지 데이터를 삭제 했습니다.
      public static let removeCache = ShopLivePlayerDemoStrings.tr("shoplive", "menu.msg.removeCache")
    }

    public enum Userinfo {
    /// SecretKey Setting
      public static let secretkey = ShopLivePlayerDemoStrings.tr("shoplive", "menu.userinfo.secretkey")
    }
  }

  public enum Referrer {

    public enum Alert {
    /// 예) shoplive
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "referrer.alert.placeholder")
    }
  }

  public enum Sample {

    public enum Coupon {
    /// Download Coupon
      public static let download = ShopLivePlayerDemoStrings.tr("shoplive", "sample.coupon.download")
      /// Coupon ID
      public static let id = ShopLivePlayerDemoStrings.tr("shoplive", "sample.coupon.id")
    }
  }

  public enum Sdk {
  /// Play
    public static let play = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.play")
    /// Preview
    public static let preview = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.preview")

    public enum Menu {
    /// 추가
      public static let add = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.menu.add")
    }

    public enum Msg {
    /// 선택된 키가 없습니다.
      public static let nonekey = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.msg.nonekey")
    }

    public enum Page {

      public enum AddParam {
      /// 파라미터 설정
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.page.addParam.title")
      }
    }

    public enum User {
    /// 지우기
      public static let delete = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.user.delete")
      /// 저장
      public static let save = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.user.save")

      public enum Secret {
      /// 추가
        public static let add = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.user.secret.add")
      }
    }
  }

  public enum SdkOption {

    public enum PipFixedHeight {
    /// 서로 다른 해상도의 단말에서 세로사이즈를 동일하게 유지하도록 고정 세로 길이를 설정할 수 있습니다.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedHeight.description")
      /// PIP 고정 높이 설정
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedHeight.title")
    }

    public enum PipFixedWidth {
    /// 서로 다른 해상도의 단말에서 가로사이즈를 동일하게 유지하도록 고정 가로 길이를 설정할 수 있습니다.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedWidth.description")
      /// PIP 고정 넓이 설정
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedWidth.title")
    }

    public enum PipMaxSize {
    /// 설정된 길이의 정사각형 안에서 영상이 잘리지 않도록 최대한 크게 보여줍니다.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipMaxSize.description")
      /// PIP Max Size 설정
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipMaxSize.title")
    }
  }

  public enum Sdkoption {

    public enum AddParameter {
    /// 커스텀 파라미터 추가
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.addParameter.title")
    }

    public enum CallOption {
    /// 통화 종료 후, 영상을 자동으로 재생합니다.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.callOption.description")
      /// 통화 옵션
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.callOption.title")
    }

    public enum ChatInputCustomFont {
    /// 미사용시, 시스템 기본 폰트가 사용됨
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.chatInputCustomFont.description")
      /// 채팅 입력창 커스텀 폰트 사용하기
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.chatInputCustomFont.title")
    }

    public enum ChatSendButtonCustomFont {
    /// 미사용시, 시스템 기본 폰트가 사용됨
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.chatSendButtonCustomFont.description")
      /// 채팅 전송 버튼 커스텀 폰트 사용하기
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.chatSendButtonCustomFont.title")
    }

    public enum Clicklog {
    /// Click log 를 Toast 로 나타냅니다.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.clicklog.description")
      /// Click log Toast 옵션
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.clicklog.title")
    }

    public enum CustomProgress {
    /// 사용시, 로딩 프로그레스 색상 적용 안됨
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.customProgress.description")
      /// 로딩 프로그레스 이미지 애니메이션 사용하기
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.customProgress.title")
    }

    public enum CustomShare {
    /// 공유하기 UI를 직접 구현 합니다.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.customShare.description")
      /// 커스텀 공유하기 사용
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.customShare.title")
    }

    public enum EnablePictureInPictureMode {
    /// Enable user to use PIP mode while watching live streaming.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.enablePictureInPictureMode.description")
      /// Enable PIP Mode
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.enablePictureInPictureMode.title")
    }

    public enum HeadphoneOption1 {
    /// Enabling this option, the video will keep playing even if the earphone/headset is disconnected.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption1.description")
      /// When an earphone/headset is disconnected
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption1.title")

      public enum Setting {
      /// Earphone or headset is disconnected
        public static let guide = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption1.setting.guide")
      }
    }

    public enum HeadphoneOption2 {
    /// 이 옵션을 활성화 하면 이어폰/헤드셋 연결이 끊겼을 때 음소거 상태로 처리할 수 있습니다. 기본 : false 볼륨 유지, true 음소거 처리.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption2.description")
      /// 이어폰/헤드셋 연결이 끊겼을 때 음소거
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption2.title")
    }

    public enum NextActionTypeOnNavigation {
    /// Sets the Synchronized Shoplive Player action when a user taps a link.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.description")
      /// Switch PIP mode
      public static let item1 = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.item1")
      /// No change
      public static let item2 = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.item2")
      /// Exit
      public static let item3 = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.item3")
      /// Synchronized Shoplive Player action when a user taps a link
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.title")
    }

    public enum PipEnableSwipeOutOption {
    /// 화면 밖으로 PIP를 SWIPE 하는 경우 플레이어를 종료시킬지 여부를 설정합니다. preview는 해당없음. in-app pip만 적용되는 옵션입니다. (기본은 종료, 설정해제 시 종료되지 않음.)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipEnableSwipeOutOption.description")
      /// 화면 밖으로 PIP를 SWIPE하는 경우 종료 여부 설정
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipEnableSwipeOutOption.title")
    }

    public enum PipFloatingOffset {
    /// PIP의 영역을 설정합니다.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.description")
      /// PIP 영역 설정
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.title")

      public enum Page {
      /// PIP 영역 설정
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.page.title")
      }
    }

    public enum PipKeepWindowStyle {
    /// OS PIP에서 앱으로 복귀할때 옵션을 true로 설정 할 경우 마지막 실행 중이던 상태(앱 내 PIP 또는 Fullscreen)로 복귀되도록 설정. (기본은 유지안함)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipKeepWindowStyle.description")
      /// OS PIP에서 앱으로 복귀할 때 윈도우스타일 유지 여부 설정
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipKeepWindowStyle.title")
    }

    public enum PipPosition {
    /// PIP 모드가 시작될 때 위치입니다. (기본은 bottomRight)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipPosition.description")
      /// PIP Position
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipPosition.title")
    }

    public enum PipScale {
    /// PIP view size.\nDisplays the scaled size based on the View width. (value between 0.1 and 1.0)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipScale.description")
      /// View size
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipScale.title")
    }

    public enum Preview {
    /// Play When Preview Tapped
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.description")
      /// Preview Tap to Play
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.title")

      public enum Closebutton {
      /// Preview 와 Inapp PIP에서 닫기버튼 사용여부를 설정합니다.(기본은 사용안함)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.closebutton.description")
        /// Use close button
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.closebutton.title")
      }
    }

    public enum ProgressColor {
    /// 설정 안함(기본값 #FFFFFF)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.progressColor.description")
      /// 로딩 프로그레스 색상(#hex값)
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.progressColor.title")
    }

    public enum Section {

      public enum AutoPlay {
      /// 자동재생
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.autoPlay.title")
      }

      public enum ChatFont {
      /// 채팅 폰트
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.chatFont.title")
      }

      public enum Clicklog {
      /// Click log
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.clicklog.title")
      }

      public enum CustomOption {
      /// 커스텀 설정
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.customOption.title")
      }

      public enum Pip {
      /// PIP (Picture in Picture)
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.pip.title")
      }

      public enum Preview {
      /// Preview
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.preview.title")
      }

      public enum Progress {
      /// 로딩 프로그레스
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.progress.title")
      }

      public enum SetupPlayer {
      /// Setup Shoplive Player
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.setupPlayer.title")
      }

      public enum Share {
      /// 공유하기
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.share.title")
      }

      public enum Sound {
      /// Sound
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.sound.title")
      }
    }

    public enum SetupPlayer {

      public enum AspectOnTablet {
      /// 영상을 화면을 꽉 채우기(off) / 영상 사이즈에 맞추기(on)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.aspectOnTablet.description")
        /// 태블릿 PC에서 영상 화면 비율 설정
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.aspectOnTablet.title")
      }

      public enum KeepWindowStateOnPlayExecuted {
      /// 항상 전체화면으로 실행(false) / 항상 현재 화면 상태를 유지(true) 기본값 false 다른 방송으로 변경시에는 전체화면으로 실행됩니다.
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.description")
        /// 플레이어가 실행 중일때 Play 호출시 화면 상태 유지 여부 설정
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.title")
      }

      public enum ManualRotation {
      /// 가로방송에서 회전 버튼이 눌렸을 때 SDK에서 화면 회전을 직접 컨트롤(false - 기본값), 회전 버튼이 눌렸을 때 고객사 앱에서 직접 회전에 대한 처리(true)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.manualRotation.description")
        /// 가로방송에서 회전 버튼에 대한 화면 회전 컨트롤을 직접 설정
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.manualRotation.title")
      }

      public enum MixAudio {
      /// Player의 audio와 다른 audio와 혼용가능합니다.
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.mixAudio.description")
        /// Player mix audio 옵션
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.mixAudio.title")
      }
    }

    public enum ShareScheme {
    /// 공유하기에 사용할 scheme 또는 url을 입력하세요
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.shareScheme.description")
      /// 공유하기 scheme 또는 URL
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.shareScheme.title")
    }

    public enum Sound {

      public enum Mute {
      /// Muted when play starts video
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.sound.mute.description")
        /// Muted play starts
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.sound.mute.title")
      }
    }

    public enum Statusbarvisibility {
    /// Visible player's status bar (default : on)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.statusbarvisibility.description")
      /// Player statusBar Visibility Option
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.statusbarvisibility.title")
    }
  }

  public enum Userinfo {

    public enum Add {

      public enum Parameter {

        public enum Button {
        /// 파라미터 추가
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.button.title")
        }

        public enum Delete {
        /// 삭제
          public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.delete.placeholder")
        }

        public enum Key {
        /// key
          public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.key.placeholder")
        }

        public enum Value {
        /// value
          public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.value.placeholder")
        }
      }
    }

    public enum Age {
    /// age
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.age.placeholder")
    }

    public enum Alert {

      public enum Placeholder {

        public enum Customer {
        /// Customer
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.alert.placeholder.customer.title")
        }

        public enum SecretKey {
        /// Secret Key
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.alert.placeholder.secretKey.title")
        }
      }
    }

    public enum Auth {

      public enum `Type` {
      /// 일반 인증
        public static let common = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.auth.type.common")
        /// Guest
        public static let guest = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.auth.type.guest")
        /// JWT 토큰 인증
        public static let jwt = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.auth.type.jwt")
      }
    }

    public enum AuthToken {
    /// [Auth Token]
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.authToken.title")
    }

    public enum Button {

      public enum ChooseSecret {

        public enum Change {
        /// 변경
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.button.chooseSecret.change.title")
        }

        public enum Input {
        /// 입력
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.button.chooseSecret.input.title")
        }
      }
    }

    public enum Gender {
    /// 여
      public static let female = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.gender.female")
      /// 남
      public static let male = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.gender.male")
      /// 선택안함
      public static let `none` = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.gender.none")
    }

    public enum Jwt {

      public enum Button {
      /// JWT Generate & Save
        public static let generate = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.jwt.button.generate")
        /// 유저정보 저장하기
        public static let usersave = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.jwt.button.usersave")
      }

      public enum Result {
      /// JWT not generated
        public static let message = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.jwt.result.message")
      }
    }

    public enum Msg {

      public enum DeleteAll {
      /// 유저 정보를 모두 삭제 하시겠습니까?
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.deleteAll.title")
      }

      public enum Save {
      /// 저장 되었습니다.
        public static let success = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.success")

        public enum Failed {
        /// userId는 필수 입니다.
          public static let noneId = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.noneId")
          /// 생성된 토큰이 없습니다.
          public static let noneToken = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.noneToken")
          /// 이미 생성된 토큰입니다.
          public static let sameInfo = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.sameInfo")

          public enum Secret {
          /// 선택된 시크릿키가 없습니다.
            public static let notselected = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.secret.notselected")
          }
        }

        public enum Parameter {
        /// key:value를 다시입력해주세요
          public static let error = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.parameter.error")
        }
      }
    }

    public enum New {

      public enum Button {
      /// Save
        public static let save = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.new.button.save")
      }
    }

    public enum UserName {
    /// userName
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.userName.placeholder")
    }

    public enum UserScore {
    /// userScore
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.userScore.placeholder")
    }

    public enum Userid {
    /// userId(필수)
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.userid.placeholder")
    }
  }

  public enum UtmSource {

    public enum Alert {
    /// 예) shoplive
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "utmSource.alert.placeholder")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension ShopLivePlayerDemoStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = ShopLivePlayerDemoResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
