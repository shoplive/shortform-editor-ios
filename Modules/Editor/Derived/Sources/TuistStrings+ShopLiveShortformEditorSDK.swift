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

    public enum Alert: Sendable {

      public enum Encoding: Sendable {

        public enum Cancel: Sendable {

          public enum Title: Sendable {
          /// Cancel encoding?
            public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.alert.encoding.cancel.title.shoplive")
          }
        }
      }

      public enum Max: Sendable {

        public enum Duration: Sendable {
        /// Only videos up to %d seconds can be uploaded
          public static func shoplive(_ p1: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.alert.max.duration.shoplive",p1)
          }
        }
      }

      public enum Min: Sendable {

        public enum Duration: Sendable {
        /// Only videos over %d seconds can be uploaded
          public static func shoplive(_ p1: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.alert.min.duration.shoplive",p1)
          }
        }
      }

      public enum Shoot: Sendable {
      /// Select a Photo or Video
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.alert.shoot.shoplive")

        public enum Title: Sendable {
        /// Capture
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.alert.shoot.title.shoplive")
        }
      }

      public enum Uploading: Sendable {

        public enum Cancel: Sendable {

          public enum Title: Sendable {
          /// Cancel uploading?
            public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.alert.uploading.cancel.title.shoplive")
          }
        }
      }
    }

    public enum Cover: Sendable {

      public enum Picker: Sendable {

        public enum Btn: Sendable {

          public enum CameraRool: Sendable {
          /// Add from Camera Roll
            public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.cover.picker.btn.cameraRool.shoplive")
          }

          public enum Confirm: Sendable {
          /// Done
            public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.cover.picker.btn.confirm.shoplive")
          }
        }

        public enum Done: Sendable {
        /// Done
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.cover.picker.done.shoplive")
        }
      }
    }

    public enum Crop: Sendable {

      public enum Btn: Sendable {

        public enum Confirm: Sendable {
        /// confirm
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.crop.btn.confirm.shoplive")
        }
      }
    }

    public enum Encoding: Sendable {

      public enum Cancel: Sendable {
      /// Canceling
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.encoding.cancel.shoplive")
      }
    }

    public enum Filter: Sendable {
    /// Filter
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.shoplive")

      public enum Bright: Sendable {
      /// Bright
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.bright.shoplive")
      }

      public enum Btn: Sendable {

        public enum Confirm: Sendable {
        /// Done
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.btn.confirm.shoplive")
        }
      }

      public enum Clear: Sendable {
      /// Clear
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.clear.shoplive")
      }

      public enum Done: Sendable {
      /// Done
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.done.shoplive")
      }

      public enum Original: Sendable {
      /// Original
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.original.shoplive")
      }

      public enum Warm: Sendable {
      /// Warm
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.filter.warm.shoplive")
      }
    }

    public enum Folder: Sendable {

      public enum All: Sendable {
      /// Recent Items
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.folder.all.shoplive")
      }
    }

    public enum Gallery: Sendable {

      public enum Done: Sendable {
      /// Done
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.gallery.done.shoplive")
      }

      public enum Photo: Sendable {
      /// Photo
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.gallery.photo.shoplive")

        public enum And: Sendable {

          public enum Video: Sendable {
          /// Photos & Videos
            public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.gallery.photo.and.video.shoplive")
          }
        }
      }

      public enum Selected: Sendable {

        public enum Count: Sendable {
        /// %1$d / %2$d
          public static func shoplive(_ p1: Int, _ p2: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.gallery.selected.count.shoplive",p1, p2)
          }
        }
      }

      public enum Unsupported: Sendable {

        public enum Media: Sendable {
        /// Unsupported media
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.gallery.unsupported.media.shoplive")
        }
      }

      public enum Video: Sendable {
      /// Video
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.gallery.video.shoplive")
      }
    }

    public enum Header: Sendable {

      public enum Headline: Sendable {

        public enum Playback: Sendable {
        /// Playback Speed
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.header.headline.playback.shoplive")
        }
      }
    }

    public enum Hint: Sendable {

      public enum Tag: Sendable {
      /// #Tags
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.hint.tag.shoplive")
      }
    }

    public enum Loading: Sendable {
    /// Video Compressing...
      public static let compress = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.loading.compress")
      /// Loading
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.loading.shoplive")
      /// Thumbnail Uploading...
      public static let thumbnail = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.loading.thumbnail")
      /// Uploading...
      public static let upload = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.loading.upload")
    }

    public enum Main: Sendable {

      public enum Btn: Sendable {

        public enum Next: Sendable {
        /// Next
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.main.btn.next.shoplive")
        }
      }
    }

    public enum Modify: Sendable {
    /// Edit
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.modify.shoplive")
    }

    public enum Next: Sendable {
    /// Next
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.next.shoplive")
    }

    public enum No: Sendable {
    /// No
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.no.shoplive")
    }

    public enum Photo: Sendable {

      public enum Picker: Sendable {

        public enum Camera: Sendable {

          public enum Cell: Sendable {

            public enum Btn: Sendable {
            /// camera
              public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.photo.picker.camera.cell.btn.title")
            }
          }
        }
      }
    }

    public enum Picture: Sendable {
    /// Photo
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.picture.shoplive")
    }

    public enum PlaybackSpeed: Sendable {

      public enum Btn: Sendable {

        public enum Confirm: Sendable {
        /// Done
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.playbackSpeed.btn.confirm.shoplive")
        }
      }
    }

    public enum Preparing: Sendable {
    /// 0%
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.preparing.shoplive")
    }

    public enum Preview: Sendable {

      public enum Title: Sendable {
      /// Preview
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.preview.title.shoplive")
      }
    }

    public enum Progress: Sendable {
    /// %1$d%%
      public static func shoplive(_ p1: Int) -> String {
        return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.progress.shoplive",p1)
      }
    }

    public enum Progressing: Sendable {
    /// Processing
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.progressing.shoplive")
    }

    public enum Select: Sendable {

      public enum Gallery: Sendable {
      /// Add from Camera Roll
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.select.gallery.shoplive")
      }
    }

    public enum Title: Sendable {

      public enum Cover: Sendable {

        public enum Picker: Sendable {
        /// Set Cover
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.title.cover.picker.shoplive")
        }
      }

      public enum Crop: Sendable {
      /// Crop
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.title.crop.shoplive")
      }

      public enum Filter: Sendable {
      /// Filter
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.title.filter.shoplive")
      }

      public enum PlaybackSpeed: Sendable {
      /// Playback Speed
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.title.playbackSpeed.shoplive")
      }

      public enum Shortform: Sendable {

        public enum Data: Sendable {

          public enum Edit: Sendable {
          /// Edit
            public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.title.shortform.data.edit.shoplive")
          }
        }
      }

      public enum Video: Sendable {

        public enum Edit: Sendable {
        /// Edit
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.title.video.edit.shoplive")
        }

        public enum Upload: Sendable {
        /// Add Details
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.title.video.upload.shoplive")
        }
      }
    }

    public enum Toast: Sendable {

      public enum Duration: Sendable {

        public enum Minute: Sendable {
        /// Please select a video longer than %d seconds and shorter than %d minutes.
          public static func shoplive(_ p1: Int, _ p2: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.duration.minute.shoplive",p1, p2)
          }
        }

        public enum Second: Sendable {
        /// Please select a video longer than %d seconds and shorter than %d seconds.
          public static func shoplive(_ p1: Int, _ p2: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.duration.second.shoplive",p1, p2)
          }
        }
      }

      public enum Encoding: Sendable {

        public enum Canceled: Sendable {
        /// Encoding canceled
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.encoding.canceled.shoplive")
        }

        public enum Fail: Sendable {
        /// Encoding failed
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.encoding.fail.shoplive")
        }

        public enum Uri: Sendable {

          public enum Was: Sendable {

            public enum Not: Sendable {

              public enum Created: Sendable {
              /// Failed to create URL.
                public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.encoding.uri.was.not.created.shoplive")
              }
            }
          }
        }

        public enum Video: Sendable {

          public enum Was: Sendable {

            public enum Not: Sendable {

              public enum Exist: Sendable {
              /// Video not found.
                public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.encoding.video.was.not.exist.shoplive")
              }
            }
          }
        }
      }

      public enum Min: Sendable {

        public enum Duration: Sendable {
        /// Only videos over %.1f seconds can be uploaded
          public static func shoplive(_ p1: Float) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.min.duration.shoplive",p1)
          }
        }
      }

      public enum Need: Sendable {

        public enum Access: Sendable {

          public enum Gallery: Sendable {

            public enum Permissions: Sendable {
            /// Camera and album access is required to upload videos
              public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.need.access.gallery.permissions.shoplive")
            }
          }
        }
      }

      public enum Shortform: Sendable {

        public enum Creation: Sendable {

          public enum Failed: Sendable {
          /// Failed to create short video
            public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.shortform.creation.failed.shoplive")
          }
        }
      }

      public enum Upload: Sendable {
      /// Uploading has been canceled.
        public static let cancelled = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.toast.upload.cancelled")
      }
    }

    public enum Trim: Sendable {

      public enum Cut: Sendable {

        public enum End: Sendable {
        /// / %1$s
          public static func shoplive(_ p1: UnsafePointer<CChar>) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.trim.cut.end.shoplive",p1)
          }
        }

        public enum Sec: Sendable {
        /// %1$d sec
          public static func shoplive(_ p1: Int) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.trim.cut.sec.shoplive",p1)
          }
        }

        public enum Start: Sendable {
        /// %1$s
          public static func shoplive(_ p1: UnsafePointer<CChar>) -> String {
            return ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.trim.cut.start.shoplive",p1)
          }
        }
      }
    }

    public enum Ugc: Sendable {

      public enum Preview: Sendable {
      /// Preview
        public static let title = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.ugc.preview.title")
      }
    }

    public enum Upload: Sendable {
    /// Upload
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.upload.shoplive")

      public enum Description: Sendable {
      /// Description
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.upload.description.shoplive")

        public enum Hint: Sendable {
        /// Description
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.upload.description.hint.shoplive")
        }
      }

      public enum Tag: Sendable {
      /// Tags
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.upload.tag.shoplive")
      }

      public enum Title: Sendable {
      /// Title
        public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.upload.title.shoplive")

        public enum Hint: Sendable {
        /// Title
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.upload.title.hint.shoplive")
        }
      }
    }

    public enum Video: Sendable {
    /// Video
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.video.shoplive")
    }

    public enum Volume: Sendable {

      public enum Btn: Sendable {

        public enum Confirm: Sendable {
        /// Done
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.volume.btn.confirm.shoplive")
        }
      }

      public enum Page: Sendable {

        public enum Title: Sendable {
        /// Volume
          public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.volume.page.title.shoplive")
        }
      }
    }

    public enum Yes: Sendable {
    /// Yes
      public static let shoplive = ShopLiveShortformEditorSDKStrings.tr("Localizable", "editor.yes.shoplive")
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
