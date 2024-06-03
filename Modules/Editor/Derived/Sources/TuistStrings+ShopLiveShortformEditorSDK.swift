// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum ShopLiveShortformEditorSDKStrings {

  public enum Alert {
  /// Cancel
    public static let no = ShopLiveShortformEditorSDKStrings.tr("Localizable", "alert.no")
    /// Ok
    public static let yes = ShopLiveShortformEditorSDKStrings.tr("Localizable", "alert.yes")

    public enum Permission {

      public enum Denied {
      /// Cancel
        public static let cancel = ShopLiveShortformEditorSDKStrings.tr("Localizable", "alert.permission.denied.cancel")
        /// Please grant camera and photo library usage permission to upload videos
        public static let description = ShopLiveShortformEditorSDKStrings.tr("Localizable", "alert.permission.denied.description")
        /// Setting
        public static let setting = ShopLiveShortformEditorSDKStrings.tr("Localizable", "alert.permission.denied.setting")
        /// Permission request
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "alert.permission.denied.title")
      }
    }
  }

  public enum Editor {

    public enum Crop {

      public enum Btn {

        public enum Confirm {
        /// next
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.crop.btn.confirm.title")
        }
      }

      public enum Page {
      /// Crop
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.crop.page.title")
      }
    }

    public enum Encoding {

      public enum Cancel {

        public enum Alert {
        /// Encoding in progressing.\nAre you sure cancel encode video?
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.encoding.cancel.alert.title")
        }
      }
    }

    public enum Filter {

      public enum Btn {

        public enum Confirm {
        /// confirm
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.btn.confirm.title")
        }
      }

      public enum Page {
      /// Filter
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.page.title")
      }
    }

    public enum Main {

      public enum Btn {

        public enum Next {
        /// next
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.main.btn.next.title")
        }
      }

      public enum Page {
      /// Edit
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.main.page.title")
      }
    }

    public enum Next {
    /// Next
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.next.title")
    }

    public enum Page {
    /// Edit
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.page.title")
    }

    public enum Photopicker {

      public enum Btn {

        public enum Recent {
        /// recents
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.photopicker.btn.recent.title")
        }
      }
    }

    public enum Speed {

      public enum Btn {

        public enum Confirm {
        /// confirm
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.btn.confirm.title")
        }
      }

      public enum Caution {

        public enum Duration {
        /// Only duration under %dm is available.
          public static func limit(_ p1: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.caution.duration.limit",p1)
          }
        }
      }

      public enum Duration {
      /// %ds
        public static func label(_ p1: Int) -> String {
          return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.duration.label",p1)
        }
      }

      public enum Page {
      /// Rate
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.page.title")
      }
    }

    public enum Thumbnail {

      public enum Btn {

        public enum CameraRoll {
        /// Add from Camera
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.btn.cameraRoll.title")
        }

        public enum Confirm {
        /// confirm
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.btn.confirm.title")
        }
      }

      public enum Page {
      /// Thumbnail
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.page.title")
      }

      public enum Toast {
      /// Do you really want to quit upload process?
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.toast.title")

        public enum Btn {

          public enum Close {
          /// No
            public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.toast.btn.close.title")
          }

          public enum Confirm {
          /// Yes
            public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.toast.btn.confirm.title")
          }
        }

        public enum Upload {

          public enum Cancel {
          /// Upload has been cancelled
            public static let label = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.toast.upload.cancel.label")
          }
        }
      }
    }

    public enum Time {

      public enum Gap {

        public enum Min {

          public enum Sec {
          /// %dm%ds
            public static func label(_ p1: Int, _ p2: Int) -> String {
              return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.time.gap.min.sec.label",p1, p2)
            }
          }
        }

        public enum Sec {
        /// %ds
          public static func label(_ p1: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.time.gap.sec.label",p1)
          }
        }
      }
    }

    public enum Upload {

      public enum Cancel {

        public enum Alert {
        /// Do you really want to quit uploading process?
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.upload.cancel.alert.title")
        }
      }
    }

    public enum Volume {

      public enum Btn {

        public enum Confirm {
        /// confirm
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.volume.btn.confirm.title")
        }
      }

      public enum Page {
      /// Volume
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.volume.page.title")
      }
    }
  }

  public enum Loading {

    public enum Inprocessing {
    /// Processing
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "loading.inprocessing.title")
    }

    public enum Preparing {
    /// Preparing
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "loading.preparing.title")
    }
  }

  public enum Picker {

    public enum Warning {

      public enum Duration {

        public enum Min {
        /// Unsupported video under 0.1s.
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "picker.warning.duration.min.title")
        }
      }
    }
  }

  public enum Toast {

    public enum Cancel {

      public enum Encoding {
      /// Video encoding canceled.
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "toast.cancel.encoding.title")
      }

      public enum Uploading {
      /// Uploading has been canceled.
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "toast.cancel.uploading.title")
      }
    }

    public enum Codec {
    /// Unsupported media
      public static let notvalid = ShopLiveShortformEditorSDKStrings.tr("Localizable", "toast.codec.notvalid")
    }

    public enum Uploadinfo {
    /// please insert video title
      public static let emptyVideoTitle = ShopLiveShortformEditorSDKStrings.tr("Localizable", "toast.uploadinfo.empty_video_title")
    }
  }

  public enum Uploadinfo {

    public enum Description {
    /// Description
      public static let placeholder = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.description.placeholder")
      /// Description
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.description.title")
    }

    public enum Page {
    /// Add detail
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.page.title")
    }

    public enum Tag {
    /// #Tag
      public static let placeholder = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.tag.placeholder")
      /// Tag
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.tag.title")
    }

    public enum Title {
    /// Title
      public static let placeholder = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.title.placeholder")
      /// Title
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.title.title")
    }

    public enum Upload {
    /// Upload
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.upload.title")
    }
  }

  public enum Video {

    public enum Frame {

      public enum Slider {

        public enum Minute {

          public enum Seconds {
          /// %dm%ds
            public static func label(_ p1: Int, _ p2: Int) -> String {
              return ShopLiveShortformEditorSDKStrings.tr("Localizable", "video.frame.slider.minute.seconds.label",p1, p2)
            }
          }
        }

        public enum Seconds {
        /// %ds
          public static func label(_ p1: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "video.frame.slider.seconds.label",p1)
          }
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension ShopLiveShortformEditorSDKStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = ShopLiveShortformEditorSDKResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
