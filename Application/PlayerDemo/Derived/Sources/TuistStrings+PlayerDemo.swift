// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum PlayerDemoStrings: Sendable {

  public enum Alert: Sendable {

    public enum Login: Sendable {

      public enum Required: Sendable {
      /// Login is required. Would you like to go to the login screen?
        public static let description = PlayerDemoStrings.tr("shoplive", "alert.login.required.description")
      }
    }

    public enum Msg: Sendable {
    /// Cancel
      public static let cancel = PlayerDemoStrings.tr("shoplive", "alert.msg.cancel")
      /// Confirm
      public static let confirm = PlayerDemoStrings.tr("shoplive", "alert.msg.confirm")
      /// Delete
      public static let delete = PlayerDemoStrings.tr("shoplive", "alert.msg.delete")
      /// Failed
      public static let failed = PlayerDemoStrings.tr("shoplive", "alert.msg.failed")
      /// No
      public static let no = PlayerDemoStrings.tr("shoplive", "alert.msg.no")
      /// Yes
      public static let ok = PlayerDemoStrings.tr("shoplive", "alert.msg.ok")
      /// Save
      public static let save = PlayerDemoStrings.tr("shoplive", "alert.msg.save")
      /// Success
      public static let success = PlayerDemoStrings.tr("shoplive", "alert.msg.success")
    }
  }

  public enum Appversion: Sendable {

    public enum Alert: Sendable {
    /// e.g., 1.0.0
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "appversion.alert.placeholder")
    }
  }

  public enum Base: Sendable {

    public enum Section: Sendable {

      public enum CampaignInfo: Sendable {
      /// Campaign Info
        public static let title = PlayerDemoStrings.tr("shoplive", "base.section.campaignInfo.title")

        public enum Button: Sendable {

          public enum ChooseCampaign: Sendable {
          /// Select Campaign
            public static let title = PlayerDemoStrings.tr("shoplive", "base.section.campaignInfo.button.chooseCampaign.title")
          }
        }

        public enum Campaign: Sendable {

          public enum None: Sendable {
          /// No campaign selected.
            public static let title = PlayerDemoStrings.tr("shoplive", "base.section.campaignInfo.campaign.none.title")
          }
        }
      }

      public enum Userinfo: Sendable {
      /// User Info
        public static let title = PlayerDemoStrings.tr("shoplive", "base.section.userinfo.title")

        public enum Button: Sendable {

          public enum ChooseCampaign: Sendable {

            public enum Change: Sendable {
            /// Change
              public static let title = PlayerDemoStrings.tr("shoplive", "base.section.userinfo.button.chooseCampaign.change.title")
            }

            public enum Input: Sendable {
            /// Input
              public static let title = PlayerDemoStrings.tr("shoplive", "base.section.userinfo.button.chooseCampaign.input.title")
            }
          }
        }

        public enum None: Sendable {
        /// Enter user information.
          public static let title = PlayerDemoStrings.tr("shoplive", "base.section.userinfo.none.title")
        }
      }
    }
  }

  public enum Campaign: Sendable {

    public enum Input: Sendable {

      public enum Accesskey: Sendable {
      /// accessKey
        public static let placeholder = PlayerDemoStrings.tr("shoplive", "campaign.input.accesskey.placeholder")
      }

      public enum Campaignkey: Sendable {
      /// campaignKey
        public static let placeholder = PlayerDemoStrings.tr("shoplive", "campaign.input.campaignkey.placeholder")
      }
    }

    public enum Menu: Sendable {
    /// Delete All
      public static let deleteall = PlayerDemoStrings.tr("shoplive", "campaign.menu.deleteall")
      /// Write Manually
      public static let write = PlayerDemoStrings.tr("shoplive", "campaign.menu.write")
    }

    public enum Msg: Sendable {
    /// Invalid URL.
      public static let wrongurl = PlayerDemoStrings.tr("shoplive", "campaign.msg.wrongurl")

      public enum DeleteAll: Sendable {
      /// Would you like to delete all campaigns?
        public static let title = PlayerDemoStrings.tr("shoplive", "campaign.msg.deleteAll.title")
      }
    }
  }

  public enum Couponresponse: Sendable {

    public enum Failed: Sendable {
    /// Failed to download coupon.
      public static let `default` = PlayerDemoStrings.tr("shoplive", "couponresponse.failed.default")
      /// * Setting Action for Failed
      public static let title = PlayerDemoStrings.tr("shoplive", "couponresponse.failed.title")
    }

    public enum Msg: Sendable {
    /// Alert Setting
      public static let alert = PlayerDemoStrings.tr("shoplive", "couponresponse.msg.alert")
      /// Message
      public static let message = PlayerDemoStrings.tr("shoplive", "couponresponse.msg.message")
      /// Show Coupon
      public static let show = PlayerDemoStrings.tr("shoplive", "couponresponse.msg.show")
    }

    public enum Success: Sendable {
    /// Successfully downloaded coupon.
      public static let `default` = PlayerDemoStrings.tr("shoplive", "couponresponse.success.default")
      /// * Setting Action for Success
      public static let title = PlayerDemoStrings.tr("shoplive", "couponresponse.success.title")
    }
  }

  public enum Guide: Sendable {
  /// Use custom share
    public static let customShare = PlayerDemoStrings.tr("shoplive", "guide.customShare")
  }

  public enum Login: Sendable {

    public enum Id: Sendable {
    /// User ID
      public static let label = PlayerDemoStrings.tr("shoplive", "login.id.label")
      /// Enter User ID
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "login.id.placeholder")
    }

    public enum Pwd: Sendable {
    /// Password
      public static let label = PlayerDemoStrings.tr("shoplive", "login.pwd.label")
      /// Enter Password
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "login.pwd.placeholder")
    }

    public enum Send: Sendable {
    /// Log In
      public static let title = PlayerDemoStrings.tr("shoplive", "login.send.title")
    }
  }

  public enum Menu: Sendable {
  /// Manage Campaign List
    public static let campaigns = PlayerDemoStrings.tr("shoplive", "menu.campaigns")
    /// Set Coupon Response
    public static let coupon = PlayerDemoStrings.tr("shoplive", "menu.coupon")
    /// Exit Broadcast (End PIP)
    public static let exit = PlayerDemoStrings.tr("shoplive", "menu.exit")
    /// Options
    public static let options = PlayerDemoStrings.tr("shoplive", "menu.options")
    /// Delete Web Storage Data
    public static let removeCache = PlayerDemoStrings.tr("shoplive", "menu.removeCache")
    /// Enter User Info
    public static let userinfo = PlayerDemoStrings.tr("shoplive", "menu.userinfo")

    public enum Msg: Sendable {
    /// Web storage data has been deleted.
      public static let removeCache = PlayerDemoStrings.tr("shoplive", "menu.msg.removeCache")
    }

    public enum Userinfo: Sendable {
    /// SecretKey Setting
      public static let secretkey = PlayerDemoStrings.tr("shoplive", "menu.userinfo.secretkey")
    }
  }

  public enum Referrer: Sendable {

    public enum Alert: Sendable {
    /// e.g., shoplive
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "referrer.alert.placeholder")
    }
  }

  public enum Sample: Sendable {

    public enum Coupon: Sendable {
    /// Download Coupon
      public static let download = PlayerDemoStrings.tr("shoplive", "sample.coupon.download")
      /// Coupon ID
      public static let id = PlayerDemoStrings.tr("shoplive", "sample.coupon.id")
    }
  }

  public enum Sdk: Sendable {
  /// Play
    public static let play = PlayerDemoStrings.tr("shoplive", "sdk.play")
    /// Preview
    public static let preview = PlayerDemoStrings.tr("shoplive", "sdk.preview")

    public enum Menu: Sendable {
    /// Add
      public static let add = PlayerDemoStrings.tr("shoplive", "sdk.menu.add")
    }

    public enum Msg: Sendable {
    /// No key selected.
      public static let nonekey = PlayerDemoStrings.tr("shoplive", "sdk.msg.nonekey")
    }

    public enum Page: Sendable {

      public enum AddParam: Sendable {
      /// Set Parameter
        public static let title = PlayerDemoStrings.tr("shoplive", "sdk.page.addParam.title")
      }
    }

    public enum User: Sendable {
    /// Delete
      public static let delete = PlayerDemoStrings.tr("shoplive", "sdk.user.delete")
      /// Save
      public static let save = PlayerDemoStrings.tr("shoplive", "sdk.user.save")

      public enum Secret: Sendable {
      /// Add
        public static let add = PlayerDemoStrings.tr("shoplive", "sdk.user.secret.add")
      }
    }
  }

  public enum SdkOption: Sendable {

    public enum PipFixedHeight: Sendable {
    /// Set a fixed vertical size to maintain the same vertical size across different resolutions.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedHeight.description")
      /// PIP Fixed Height Setting
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedHeight.title")
    }

    public enum PipFixedWidth: Sendable {
    /// Set a fixed horizontal size to maintain the same horizontal size across different resolutions.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedWidth.description")
      /// PIP Fixed Width Setting
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkOption.pipFixedWidth.title")
    }

    public enum PipMaxSize: Sendable {
    /// Displays the video as large as possible within a square of set length without cutting off.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkOption.pipMaxSize.description")
      /// PIP Max Size Setting
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkOption.pipMaxSize.title")
    }
  }

  public enum Sdkoption: Sendable {

    public enum AddParameter: Sendable {
    /// Add Custom Parameter
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.addParameter.title")
    }

    public enum CallOption: Sendable {
    /// Automatically resumes video after a call ends.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.callOption.description")
      /// Call Option
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.callOption.title")
    }

    public enum ChatInputCustomFont: Sendable {
    /// If not used, system default font is used
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.chatInputCustomFont.description")
      /// Use Custom Font for Chat Input
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.chatInputCustomFont.title")
    }

    public enum ChatSendButtonCustomFont: Sendable {
    /// If not used, system default font is used
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.chatSendButtonCustomFont.description")
      /// Use Custom Font for Chat Send Button
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.chatSendButtonCustomFont.title")
    }

    public enum Clicklog: Sendable {
    /// Display Click log as Toast.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.clicklog.description")
      /// Click Log Toast Option
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.clicklog.title")
    }

    public enum CustomProgress: Sendable {
    /// If used, loading progress color will not be applied
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.customProgress.description")
      /// Use Loading Progress Image Animation
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.customProgress.title")
    }

    public enum CustomShare: Sendable {
    /// Implement your own share UI.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.customShare.description")
      /// Use Custom Share
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.customShare.title")
    }

    public enum EnableOspip: Sendable {
    /// Enables OSPIP (Default : true)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.enableOspip.description")
      /// Enable OSPIP
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.enableOspip.title")
    }

    public enum EnablePictureInPictureMode: Sendable {
    /// Enable user to use PIP mode while watching live streaming.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.enablePictureInPictureMode.description")
      /// Enable PIP Mode
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.enablePictureInPictureMode.title")
    }

    public enum Enablepip: Sendable {
    /// Enables InAppPip,Preview,OSPIP (default : true)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.enablepip.description")
      /// Enable PIP
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.enablepip.title")
    }

    public enum HeadphoneOption1: Sendable {
    /// Enabling this option, the video will keep playing even if the earphone/headset is disconnected.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption1.description")
      /// When an earphone/headset is disconnected
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption1.title")

      public enum Setting: Sendable {
      /// Earphone or headset is disconnected
        public static let guide = PlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption1.setting.guide")
      }
    }

    public enum HeadphoneOption2: Sendable {
    /// If this option is enabled, the video will be muted if the earphone/headset is disconnected. Default: false keep volume, true mute.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption2.description")
      /// Mute when earphone/headset is disconnected
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.headphoneOption2.title")
    }

    public enum NextActionTypeOnNavigation: Sendable {
    /// Sets the Synchronized Shoplive Player action when a user taps a link.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.description")
      /// Switch PIP mode
      public static let item1 = PlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.item1")
      /// No change
      public static let item2 = PlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.item2")
      /// Exit
      public static let item3 = PlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.item3")
      /// Synchronized Shoplive Player action when a user taps a link
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.nextActionTypeOnNavigation.title")
    }

    public enum PinPosition: Sendable {
    /// Position of where PIP can be pinned. (default is [topLeft, topRight, bottomLeft, bottomRight])
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.pinPosition.description")
      /// PIP Pin Position
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.pinPosition.title")
    }

    public enum PipCornerRadius: Sendable {
    /// Set the corner radius of InAppPip. (default 10)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.pipCornerRadius.description")
      /// InAppPip Corner Radius
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.pipCornerRadius.title")
    }

    public enum PipEnableSwipeOutOption: Sendable {
    /// Set whether to terminate the player when PIP is swiped out of the screen. No application for preview. in-app pip only. (default is to terminate, if not set then will not terminate)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.pipEnableSwipeOutOption.description")
      /// Set whether to exit player when PIP is swiped out of the screen
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.pipEnableSwipeOutOption.title")
    }

    public enum PipFloatingOffset: Sendable {
    /// Set the area of PIP.
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.description")
      /// PIP Area Setting
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.title")

      public enum Page: Sendable {
      /// PIP Area Setting
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.pipFloatingOffset.page.title")
      }
    }

    public enum PipKeepWindowStyle: Sendable {
    /// Set the option to true if you want to return to the last state running (in-app PIP or Fullscreen) when returning from OS PIP. (default is not maintained)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.pipKeepWindowStyle.description")
      /// Maintain Window Style when returning to app from OS PIP
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.pipKeepWindowStyle.title")
    }

    public enum PipPosition: Sendable {
    /// Position of PIP mode when it starts. (default is bottomRight)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.pipPosition.description")
      /// PIP Position
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.pipPosition.title")
    }

    public enum PipScale: Sendable {
    /// PIP view size.\nDisplays the scaled size based on the View width. (value between 0.1 and 1.0)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.pipScale.description")
      /// View Size
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.pipScale.title")
    }

    public enum Player: Sendable {

      public enum Preview: Sendable {
      /// Set resolution type in preview. (Default is preview type, ON -> Preview)
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.player.preview.description")
        /// Preview resolution type
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.player.preview.title")
      }
    }

    public enum Preview: Sendable {
    /// Play when preview tapped
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.preview.description")
      /// Preview Tap to Play
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.preview.title")

      public enum Closebutton: Sendable {
      /// Set whether to use the close button in preview and in-app PIP (default is not to use)
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.preview.closebutton.description")
        /// Use Close Button
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.preview.closebutton.title")
      }

      public enum EnableSound: Sendable {
      /// Set whether to mute in Preview. (Default is true)
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.preview.enableSound.description")
        /// Preview muted
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.preview.enableSound.title")
      }
    }

    public enum ProgressColor: Sendable {
    /// None set (default #FFFFFF)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.progressColor.description")
      /// Loading Progress Color (#hex value)
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.progressColor.title")
    }

    public enum Section: Sendable {

      public enum AutoPlay: Sendable {
      /// Auto Play
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.autoPlay.title")
      }

      public enum ChatFont: Sendable {
      /// Chat Font
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.chatFont.title")
      }

      public enum Clicklog: Sendable {
      /// Click Log
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.clicklog.title")
      }

      public enum CustomOption: Sendable {
      /// Custom Setting
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.customOption.title")
      }

      public enum Pip: Sendable {
      /// PIP (Picture in Picture)
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.pip.title")
      }

      public enum Preview: Sendable {
      /// Preview
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.preview.title")
      }

      public enum Progress: Sendable {
      /// Loading Progress
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.progress.title")
      }

      public enum SetupPlayer: Sendable {
      /// Setup Shoplive Player
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.setupPlayer.title")
      }

      public enum Share: Sendable {
      /// Share
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.share.title")
      }

      public enum Sound: Sendable {
      /// Sound
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.section.sound.title")
      }
    }

    public enum SetupPlayer: Sendable {

      public enum AspectOnTablet: Sendable {
      /// Fill screen with video (off) / Fit video size (on)
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.aspectOnTablet.description")
        /// Set Video Aspect Ratio on Tablet PC
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.aspectOnTablet.title")
      }

      public enum IsEnabledVolumeKey: Sendable {
      /// Enable listening to hardware volume key events (default : false)
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.isEnabledVolumeKey.description")
        /// HW volume btn Event Option
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.isEnabledVolumeKey.title")
      }

      public enum KeepWindowStateOnPlayExecuted: Sendable {
      /// Always launch in full screen (false) / Always keep current window state (true) Default is false, when changing to another broadcast, it is executed in full screen.
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.description")
        /// Keep Window State when Play is Executed
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.title")
      }

      public enum ManualRotation: Sendable {
      /// Control screen rotation directly in SDK when rotation button is pressed in horizontal broadcast (false - default), Handle rotation directly in client app when rotation button is pressed (true)
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.manualRotation.description")
        /// Manual Rotation Control in Horizontal Broadcast
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.manualRotation.title")
      }

      public enum MixAudio: Sendable {
      /// Allows mixing of player's audio with other audio.
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.mixAudio.description")
        /// Player Mix Audio Option
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.mixAudio.title")
      }

      public enum ResizeMode: Sendable {
      /// Set Players render option (default : CENTER_CROP)
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.resizeMode.description")
        /// Player View resize option
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.setupPlayer.resizeMode.title")
      }
    }

    public enum ShareScheme: Sendable {
    /// Enter the scheme or url to use for sharing
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.shareScheme.description")
      /// Share Scheme or URL
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.shareScheme.title")
    }

    public enum Sound: Sendable {

      public enum Mute: Sendable {
      /// Muted when play starts video
        public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.sound.mute.description")
        /// Muted Play Starts
        public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.sound.mute.title")
      }
    }

    public enum Statusbarvisibility: Sendable {
    /// Visible player's status bar (default : on)
      public static let description = PlayerDemoStrings.tr("shoplive", "sdkoption.statusbarvisibility.description")
      /// Player StatusBar Visibility Option
      public static let title = PlayerDemoStrings.tr("shoplive", "sdkoption.statusbarvisibility.title")
    }
  }

  public enum Userinfo: Sendable {

    public enum Add: Sendable {

      public enum Parameter: Sendable {

        public enum Button: Sendable {
        /// Add Parameter
          public static let title = PlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.button.title")
        }

        public enum Delete: Sendable {
        /// Delete
          public static let placeholder = PlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.delete.placeholder")
        }

        public enum Key: Sendable {
        /// key
          public static let placeholder = PlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.key.placeholder")
        }

        public enum Value: Sendable {
        /// value
          public static let placeholder = PlayerDemoStrings.tr("shoplive", "userinfo.add.parameter.value.placeholder")
        }
      }
    }

    public enum Age: Sendable {
    /// age
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "userinfo.age.placeholder")
    }

    public enum Alert: Sendable {

      public enum Placeholder: Sendable {

        public enum Customer: Sendable {
        /// Customer
          public static let title = PlayerDemoStrings.tr("shoplive", "userinfo.alert.placeholder.customer.title")
        }

        public enum SecretKey: Sendable {
        /// Secret Key
          public static let title = PlayerDemoStrings.tr("shoplive", "userinfo.alert.placeholder.secretKey.title")
        }
      }
    }

    public enum Auth: Sendable {

      public enum `Type`: Sendable {
      /// Common Authentication
        public static let common = PlayerDemoStrings.tr("shoplive", "userinfo.auth.type.common")
        /// Guest
        public static let guest = PlayerDemoStrings.tr("shoplive", "userinfo.auth.type.guest")
        /// JWT Token Authentication
        public static let jwt = PlayerDemoStrings.tr("shoplive", "userinfo.auth.type.jwt")
      }
    }

    public enum AuthToken: Sendable {
    /// [Auth Token]
      public static let title = PlayerDemoStrings.tr("shoplive", "userinfo.authToken.title")
    }

    public enum Button: Sendable {

      public enum ChooseSecret: Sendable {

        public enum Change: Sendable {
        /// Change
          public static let title = PlayerDemoStrings.tr("shoplive", "userinfo.button.chooseSecret.change.title")
        }

        public enum Input: Sendable {
        /// Input
          public static let title = PlayerDemoStrings.tr("shoplive", "userinfo.button.chooseSecret.input.title")
        }
      }
    }

    public enum Gender: Sendable {
    /// Female
      public static let female = PlayerDemoStrings.tr("shoplive", "userinfo.gender.female")
      /// Male
      public static let male = PlayerDemoStrings.tr("shoplive", "userinfo.gender.male")
      /// Do Not Select
      public static let `none` = PlayerDemoStrings.tr("shoplive", "userinfo.gender.none")
    }

    public enum Jwt: Sendable {

      public enum Button: Sendable {
      /// JWT Generate & Save
        public static let generate = PlayerDemoStrings.tr("shoplive", "userinfo.jwt.button.generate")
        /// Save User Info
        public static let usersave = PlayerDemoStrings.tr("shoplive", "userinfo.jwt.button.usersave")
      }

      public enum Result: Sendable {
      /// JWT not generated
        public static let message = PlayerDemoStrings.tr("shoplive", "userinfo.jwt.result.message")
      }
    }

    public enum Msg: Sendable {

      public enum DeleteAll: Sendable {
      /// Would you like to delete all user information?
        public static let title = PlayerDemoStrings.tr("shoplive", "userinfo.msg.deleteAll.title")
      }

      public enum Save: Sendable {
      /// Saved successfully.
        public static let success = PlayerDemoStrings.tr("shoplive", "userinfo.msg.save.success")

        public enum Failed: Sendable {
        /// userId is required.
          public static let noneId = PlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.noneId")
          /// No token generated.
          public static let noneToken = PlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.noneToken")
          /// Token already generated.
          public static let sameInfo = PlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.sameInfo")

          public enum Secret: Sendable {
          /// No secret key selected.
            public static let notselected = PlayerDemoStrings.tr("shoplive", "userinfo.msg.save.failed.secret.notselected")
          }
        }

        public enum Parameter: Sendable {
        /// Please re-enter key:value
          public static let error = PlayerDemoStrings.tr("shoplive", "userinfo.msg.save.parameter.error")
        }
      }
    }

    public enum New: Sendable {

      public enum Button: Sendable {
      /// Save
        public static let save = PlayerDemoStrings.tr("shoplive", "userinfo.new.button.save")
      }
    }

    public enum UserName: Sendable {
    /// userName
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "userinfo.userName.placeholder")
    }

    public enum UserScore: Sendable {
    /// userScore
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "userinfo.userScore.placeholder")
    }

    public enum Userid: Sendable {
    /// userId (required)
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "userinfo.userid.placeholder")
    }
  }

  public enum Utm: Sendable {

    public enum Alert: Sendable {
    /// e.g., shoplive
      public static let placeholder = PlayerDemoStrings.tr("shoplive", "utm.alert.placeholder")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension PlayerDemoStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
