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
      /// Login is required. Would you like to go to the login screen?
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "alert.login.required.description")
      }
    }

    public enum Msg {
    /// Cancel
      public static let cancel = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.cancel")
      /// Confirm
      public static let confirm = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.confirm")
      /// Delete
      public static let delete = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.delete")
      /// Failed
      public static let failed = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.failed")
      /// No
      public static let no = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.no")
      /// Yes
      public static let ok = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.ok")
      /// Save
      public static let save = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.save")
      /// Success
      public static let success = ShopLivePlayerDemoStrings.tr("shoplive", "alert.msg.success")
    }
  }

  public enum Appversion {

    public enum Alert {
    /// e.g., 1.0.0
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "appversion.alert.placeholder")
    }
  }

  public enum Base {

    public enum Section {

      public enum CampaignInfo {
      /// Campaign Info
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.campaignInfo.title")

        public enum Button {

          public enum ChooseCampaign {
          /// Select Campaign
            public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.campaignInfo.button.chooseCampaign.title")
          }
        }

        public enum Campaign {

          public enum None {
          /// No campaign selected.
            public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.campaignInfo.campaign.none.title")
          }
        }
      }

      public enum Userinfo {
      /// User Info
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.userinfo.title")

        public enum Button {

          public enum ChooseCampaign {

            public enum Change {
            /// Change
              public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.userinfo.button.chooseCampaign.change.title")
            }

            public enum Input {
            /// Input
              public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "base.section.userinfo.button.chooseCampaign.input.title")
            }
          }
        }

        public enum None {
        /// Enter user information.
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
    /// Delete All
      public static let deleteall = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.menu.deleteall")
      /// Write Manually
      public static let write = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.menu.write")
    }

    public enum Msg {
    /// Invalid URL.
      public static let wrongurl = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.msg.wrongurl")

      public enum DeleteAll {
      /// Would you like to delete all campaigns?
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "campaign.msg.deleteAll.title")
      }
    }
  }

  public enum Couponresponse {

    public enum Failed {
    /// Failed to download coupon.
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
    /// Successfully downloaded coupon.
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
  /// Manage Campaign List
    public static let campaigns = ShopLivePlayerDemoStrings.tr("shoplive", "menu.campaigns")
    /// Set Coupon Response
    public static let coupon = ShopLivePlayerDemoStrings.tr("shoplive", "menu.coupon")
    /// Exit Broadcast (End PIP)
    public static let exit = ShopLivePlayerDemoStrings.tr("shoplive", "menu.exit")
    /// Options
    public static let options = ShopLivePlayerDemoStrings.tr("shoplive", "menu.options")
    /// Delete Web Storage Data
    public static let removeCache = ShopLivePlayerDemoStrings.tr("shoplive", "menu.removeCache")
    /// Enter User Info
    public static let userinfo = ShopLivePlayerDemoStrings.tr("shoplive", "menu.userinfo")

    public enum Msg {
    /// Web storage data has been deleted.
      public static let removeCache = ShopLivePlayerDemoStrings.tr("shoplive", "menu.msg.removeCache")
    }

    public enum Userinfo {
    /// SecretKey Setting
      public static let secretkey = ShopLivePlayerDemoStrings.tr("shoplive", "menu.userinfo.secretkey")
    }
  }

  public enum Referrer {

    public enum Alert {
    /// e.g., shoplive
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
    /// Add
      public static let add = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.menu.add")
    }

    public enum Msg {
    /// No key selected.
      public static let nonekey = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.msg.nonekey")
    }

    public enum Page {

      public enum AddParam {
      /// Set Parameter
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.page.addParam.title")
      }
    }

    public enum User {
    /// Delete
      public static let delete = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.user.delete")
      /// Save
      public static let save = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.user.save")

      public enum Secret {
      /// Add
        public static let add = ShopLivePlayerDemoStrings.tr("shoplive", "sdk.user.secret.add")
      }
    }
  }

  public enum SdkOption {

    public enum PipFixedHeight {
    /// Set a fixed vertical size to maintain the same vertical size across different resolutions.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedHeight.description")
      /// PIP Fixed Height Setting
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedHeight.title")
    }

    public enum PipFixedWidth {
    /// Set a fixed horizontal size to maintain the same horizontal size across different resolutions.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedWidth.description")
      /// PIP Fixed Width Setting
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedWidth.title")
    }

    public enum PipMaxSize {
    /// Displays the video as large as possible within a square of set length without cutting off.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipMaxSize.description")
      /// PIP Max Size Setting
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkOption.pipMaxSize.title")
    }
  }

  public enum Sdkoption {

    public enum AddParameter {
    /// Add Custom Parameter
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.addParameter.title")
    }

    public enum CallOption {
    /// Automatically resumes video after a call ends.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.callOption.description")
      /// Call Option
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.callOption.title")
    }

    public enum ChatInputCustomFont {
    /// If not used, system default font is used
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.chatInputCustomFont.description")
      /// Use Custom Font for Chat Input
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.chatInputCustomFont.title")
    }

    public enum ChatSendButtonCustomFont {
    /// If not used, system default font is used
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.chatSendButtonCustomFont.description")
      /// Use Custom Font for Chat Send Button
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.chatSendButtonCustomFont.title")
    }

    public enum Clicklog {
    /// Display Click log as Toast.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.clicklog.description")
      /// Click Log Toast Option
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.clicklog.title")
    }

    public enum CustomProgress {
    /// If used, loading progress color will not be applied
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.customProgress.description")
      /// Use Loading Progress Image Animation
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.customProgress.title")
    }

    public enum CustomShare {
    /// Implement your own share UI.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.customShare.description")
      /// Use Custom Share
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.customShare.title")
    }

    public enum EnableOspip {
    /// Enables OSPIP (Default : true)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.enableOspip.description")
      /// Enable OSPIP
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.enableOspip.title")
    }

    public enum EnablePictureInPictureMode {
    /// Enable user to use PIP mode while watching live streaming.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.enablePictureInPictureMode.description")
      /// Enable PIP Mode
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.enablePictureInPictureMode.title")
    }

    public enum Enablepip {
    /// Enables InAppPip,Preview,OSPIP (default : true)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.enablepip.description")
      /// Enable PIP
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.enablepip.title")
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
    /// If this option is enabled, the video will be muted if the earphone/headset is disconnected. Default: false keep volume, true mute.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption2.description")
      /// Mute when earphone/headset is disconnected
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

    public enum PinPosition {
    /// Position of where PIP can be pinned. (default is [topLeft, topRight, bottomLeft, bottomRight])
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pinPosition.description")
      /// PIP Pin Position
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pinPosition.title")
    }

    public enum PipCornerRadius {
    /// Set the corner radius of InAppPip. (default 10)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipCornerRadius.description")
      /// InAppPip Corner Radius
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipCornerRadius.title")
    }

    public enum PipEnableSwipeOutOption {
    /// Set whether to terminate the player when PIP is swiped out of the screen. No application for preview. in-app pip only. (default is to terminate, if not set then will not terminate)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipEnableSwipeOutOption.description")
      /// Set whether to exit player when PIP is swiped out of the screen
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipEnableSwipeOutOption.title")
    }

    public enum PipFloatingOffset {
    /// Set the area of PIP.
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.description")
      /// PIP Area Setting
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.title")

      public enum Page {
      /// PIP Area Setting
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.page.title")
      }
    }

    public enum PipKeepWindowStyle {
    /// Set the option to true if you want to return to the last state running (in-app PIP or Fullscreen) when returning from OS PIP. (default is not maintained)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipKeepWindowStyle.description")
      /// Maintain Window Style when returning to app from OS PIP
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipKeepWindowStyle.title")
    }

    public enum PipPosition {
    /// Position of PIP mode when it starts. (default is bottomRight)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipPosition.description")
      /// PIP Position
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipPosition.title")
    }

    public enum PipScale {
    /// PIP view size.\nDisplays the scaled size based on the View width. (value between 0.1 and 1.0)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipScale.description")
      /// View Size
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.pipScale.title")
    }

    public enum Preview {
    /// Play when preview tapped
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.description")
      /// Preview Tap to Play
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.title")

      public enum Closebutton {
      /// Set whether to use the close button in preview and in-app PIP (default is not to use)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.closebutton.description")
        /// Use Close Button
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.closebutton.title")
      }

      public enum EnableSound {
      /// Set whether to mute in Preview. (Default is true)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.enableSound.description")
        /// Preview muted
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.preview.enableSound.title")
      }
    }

    public enum ProgressColor {
    /// None set (default #FFFFFF)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.progressColor.description")
      /// Loading Progress Color (#hex value)
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.progressColor.title")
    }

    public enum Section {

      public enum AutoPlay {
      /// Auto Play
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.autoPlay.title")
      }

      public enum ChatFont {
      /// Chat Font
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.chatFont.title")
      }

      public enum Clicklog {
      /// Click Log
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.clicklog.title")
      }

      public enum CustomOption {
      /// Custom Setting
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
      /// Loading Progress
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.progress.title")
      }

      public enum SetupPlayer {
      /// Setup Shoplive Player
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.setupPlayer.title")
      }

      public enum Share {
      /// Share
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.share.title")
      }

      public enum Sound {
      /// Sound
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.section.sound.title")
      }
    }

    public enum SetupPlayer {

      public enum AspectOnTablet {
      /// Fill screen with video (off) / Fit video size (on)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.aspectOnTablet.description")
        /// Set Video Aspect Ratio on Tablet PC
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.aspectOnTablet.title")
      }

      public enum IsEnabledVolumeKey {
      /// Enable listening to hardware volume key events (default : false)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.isEnabledVolumeKey.description")
        /// HW volume btn Event Option
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.isEnabledVolumeKey.title")
      }

      public enum KeepWindowStateOnPlayExecuted {
      /// Always launch in full screen (false) / Always keep current window state (true) Default is false, when changing to another broadcast, it is executed in full screen.
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.description")
        /// Keep Window State when Play is Executed
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.title")
      }

      public enum ManualRotation {
      /// Control screen rotation directly in SDK when rotation button is pressed in horizontal broadcast (false - default), Handle rotation directly in client app when rotation button is pressed (true)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.manualRotation.description")
        /// Manual Rotation Control in Horizontal Broadcast
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.manualRotation.title")
      }

      public enum MixAudio {
      /// Allows mixing of player's audio with other audio.
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.mixAudio.description")
        /// Player Mix Audio Option
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.mixAudio.title")
      }

      public enum ResizeMode {
      /// Set Players render option (default : CENTER_CROP)
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.resizeMode.description")
        /// Player View resize option
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.resizeMode.title")
      }
    }

    public enum ShareScheme {
    /// Enter the scheme or url to use for sharing
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.shareScheme.description")
      /// Share Scheme or URL
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.shareScheme.title")
    }

    public enum Sound {

      public enum Mute {
      /// Muted when play starts video
        public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.sound.mute.description")
        /// Muted Play Starts
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.sound.mute.title")
      }
    }

    public enum Statusbarvisibility {
    /// Visible player's status bar (default : on)
      public static let description = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.statusbarvisibility.description")
      /// Player StatusBar Visibility Option
      public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "sdkoption.statusbarvisibility.title")
    }
  }

  public enum Userinfo {

    public enum Add {

      public enum Parameter {

        public enum Button {
        /// Add Parameter
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.button.title")
        }

        public enum Delete {
        /// Delete
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
      /// Common Authentication
        public static let common = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.auth.type.common")
        /// Guest
        public static let guest = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.auth.type.guest")
        /// JWT Token Authentication
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
        /// Change
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.button.chooseSecret.change.title")
        }

        public enum Input {
        /// Input
          public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.button.chooseSecret.input.title")
        }
      }
    }

    public enum Gender {
    /// Female
      public static let female = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.gender.female")
      /// Male
      public static let male = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.gender.male")
      /// Do Not Select
      public static let `none` = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.gender.none")
    }

    public enum Jwt {

      public enum Button {
      /// JWT Generate & Save
        public static let generate = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.jwt.button.generate")
        /// Save User Info
        public static let usersave = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.jwt.button.usersave")
      }

      public enum Result {
      /// JWT not generated
        public static let message = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.jwt.result.message")
      }
    }

    public enum Msg {

      public enum DeleteAll {
      /// Would you like to delete all user information?
        public static let title = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.deleteAll.title")
      }

      public enum Save {
      /// Saved successfully.
        public static let success = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.success")

        public enum Failed {
        /// userId is required.
          public static let noneId = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.noneId")
          /// No token generated.
          public static let noneToken = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.noneToken")
          /// Token already generated.
          public static let sameInfo = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.sameInfo")

          public enum Secret {
          /// No secret key selected.
            public static let notselected = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.secret.notselected")
          }
        }

        public enum Parameter {
        /// Please re-enter key:value
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
    /// userId (required)
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "userinfo.userid.placeholder")
    }
  }

  public enum Utm {

    public enum Alert {
    /// e.g., shoplive
      public static let placeholder = ShopLivePlayerDemoStrings.tr("shoplive", "utm.alert.placeholder")
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
