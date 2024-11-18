// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum ShopLiveShortformEditorSDKStrings: Sendable {

  public enum Alert: Sendable {
  /// Cancel
    public static let no = ShopLiveShortformEditorSDKStrings.tr("Localizable", "alert.no")
    /// Ok
    public static let yes = ShopLiveShortformEditorSDKStrings.tr("Localizable", "alert.yes")

    public enum Permission: Sendable {

      public enum Denied: Sendable {
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

  public enum Editor: Sendable {

    public enum Crop: Sendable {

      public enum Btn: Sendable {

        public enum Confirm: Sendable {
        /// next
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.crop.btn.confirm.title")
        }
      }

      public enum Page: Sendable {
      /// Crop
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.crop.page.title")
      }
    }

    public enum Encoding: Sendable {

      public enum Cancel: Sendable {

        public enum Alert: Sendable {
        /// Encoding in progressing.\nAre you sure cancel encode video?
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.encoding.cancel.alert.title")
        }
      }
    }

    public enum Filter: Sendable {

      public enum Btn: Sendable {

        public enum Confirm: Sendable {
        /// confirm
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.btn.confirm.title")
        }
      }

      public enum Page: Sendable {
      /// Filter
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.page.title")
      }
    }

    public enum Main: Sendable {

      public enum Btn: Sendable {

        public enum Next: Sendable {
        /// next
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.main.btn.next.title")
        }
      }

      public enum Page: Sendable {
      /// Edit
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.main.page.title")
      }
    }

    public enum Next: Sendable {
    /// Next
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.next.title")
    }

    public enum Page: Sendable {
    /// Edit
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.page.title")
    }

    public enum Photopicker: Sendable {

      public enum Btn: Sendable {

        public enum Recent: Sendable {
        /// recents
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.photopicker.btn.recent.title")
        }
      }
    }

    public enum Speed: Sendable {

      public enum Btn: Sendable {

        public enum Confirm: Sendable {
        /// confirm
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.btn.confirm.title")
        }
      }

      public enum Caution: Sendable {

        public enum Duration: Sendable {

          public enum Limit: Sendable {
          /// Only duration under %dm is available.
            public static func min(_ p1: Int) -> String {
              return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.caution.duration.limit.min",p1)
            }
            /// Only duration under %dsec is available.
            public static func sec(_ p1: Int) -> String {
              return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.caution.duration.limit.sec",p1)
            }
          }
        }
      }

      public enum Duration: Sendable {
      /// %ds
        public static func label(_ p1: Int) -> String {
          return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.duration.label",p1)
        }
      }

      public enum Page: Sendable {
      /// Rate
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.speed.page.title")
      }
    }

    public enum Thumbnail: Sendable {

      public enum Btn: Sendable {

        public enum CameraRoll: Sendable {
        /// Add from Camera
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.btn.cameraRoll.title")
        }

        public enum Confirm: Sendable {
        /// confirm
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.btn.confirm.title")
        }
      }

      public enum Page: Sendable {
      /// Thumbnail
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.page.title")
      }

      public enum Toast: Sendable {
      /// Do you really want to quit upload process?
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.toast.title")

        public enum Btn: Sendable {

          public enum Close: Sendable {
          /// No
            public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.toast.btn.close.title")
          }

          public enum Confirm: Sendable {
          /// Yes
            public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.toast.btn.confirm.title")
          }
        }

        public enum Upload: Sendable {

          public enum Cancel: Sendable {
          /// Upload has been cancelled
            public static let label = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.thumbnail.toast.upload.cancel.label")
          }
        }
      }
    }

    public enum Time: Sendable {

      public enum Gap: Sendable {

        public enum Min: Sendable {

          public enum Sec: Sendable {
          /// %dm%ds
            public static func label(_ p1: Int, _ p2: Int) -> String {
              return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.time.gap.min.sec.label",p1, p2)
            }
          }
        }

        public enum Sec: Sendable {
        /// %ds
          public static func label(_ p1: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.time.gap.sec.label",p1)
          }
        }
      }
    }

    public enum Upload: Sendable {

      public enum Cancel: Sendable {

        public enum Alert: Sendable {
        /// Do you really want to quit process?
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.upload.cancel.alert.title")
        }
      }
    }

    public enum Volume: Sendable {

      public enum Btn: Sendable {

        public enum Confirm: Sendable {
        /// confirm
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.volume.btn.confirm.title")
        }
      }

      public enum Page: Sendable {
      /// Volume
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.volume.page.title")
      }
    }
  }

  public enum Loading: Sendable {

    public enum Inprocessing: Sendable {
    /// Processing
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "loading.inprocessing.title")
    }

    public enum Preparing: Sendable {
    /// Preparing
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "loading.preparing.title")
    }
  }

  public enum Picker: Sendable {

    public enum Warning: Sendable {

      public enum Duration: Sendable {

        public enum Invalid: Sendable {
        /// Please select video duration between %dsec and %dmin
          public static func message(_ p1: Int, _ p2: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "picker.warning.duration.invalid.message",p1, p2)
          }
        }

        public enum Min: Sendable {
        /// Unsupported video under 0.1s.
          public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "picker.warning.duration.min.title")
        }
      }
    }
  }

  public enum Toast: Sendable {

    public enum Cancel: Sendable {

      public enum Encoding: Sendable {
      /// Video encoding canceled.
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "toast.cancel.encoding.title")
      }

      public enum Uploading: Sendable {
      /// Uploading has been canceled.
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "toast.cancel.uploading.title")
      }
    }

    public enum Codec: Sendable {
    /// Unsupported media
      public static let notvalid = ShopLiveShortformEditorSDKStrings.tr("Localizable", "toast.codec.notvalid")
    }

    public enum Uploadinfo: Sendable {
    /// please insert video title
      public static let emptyVideoTitle = ShopLiveShortformEditorSDKStrings.tr("Localizable", "toast.uploadinfo.empty_video_title")
    }
  }

  public enum Uploadinfo: Sendable {

    public enum Description: Sendable {
    /// Description
      public static let placeholder = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.description.placeholder")
      /// Description
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.description.title")
    }

    public enum Page: Sendable {
    /// Add detail
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.page.title")
    }

    public enum Tag: Sendable {
    /// #Tag
      public static let placeholder = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.tag.placeholder")
      /// Tag
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.tag.title")
    }

    public enum Title: Sendable {
    /// Title
      public static let placeholder = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.title.placeholder")
      /// Title
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.title.title")
    }

    public enum Upload: Sendable {
    /// Upload
      public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "uploadinfo.upload.title")
    }
  }

  public enum Video: Sendable {

    public enum Frame: Sendable {

      public enum Slider: Sendable {

        public enum Minute: Sendable {

          public enum Seconds: Sendable {
          /// %dm%ds
            public static func label(_ p1: Int, _ p2: Int) -> String {
              return ShopLiveShortformEditorSDKStrings.tr("Localizable", "video.frame.slider.minute.seconds.label",p1, p2)
            }
          }
        }

        public enum Seconds: Sendable {
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
    let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
