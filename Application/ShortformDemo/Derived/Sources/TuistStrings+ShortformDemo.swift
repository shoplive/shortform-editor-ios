// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum ShortformDemoStrings: Sendable {
  /// Cancel
  public static let eoExportCancel = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cancel")
  /// Confirm
  public static let eoExportConfirm = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_confirm")
  /// Import from album
  public static let eoExportCoverAlbum = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_album")
  /// Confirm
  public static let eoExportCoverConfirm = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_confirm")
  /// Set video cover
  public static let eoExportCoverEditor = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_editor")
  /// Done
  public static let eoExportCoverFinish = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_finish")
  /// Select video frame
  public static let eoExportCoverFrame = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_frame")
  /// Drag the pointer to set select video frame
  public static let eoExportCoverOperation = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_operation")
  /// Saved to local album
  public static let eoExportCoverSavetolocal = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_savetolocal")
  /// Select again
  public static let eoExportCoverSelectagain = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_selectagain")
  /// Drag or double finger zoom to adjust the image
  public static let eoExportCoverTip = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_cover_tip")
  /// Cancel export
  public static let eoExportExitExportTip = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_exit_export_tip")
  /// Exiting now will loss all current progress, confirm?
  public static let eoExportExitMessage = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_exit_message")
  /// Confirm to exit export?
  public static let eoExportExitTitle = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_exit_title")
  /// Export
  public static let eoExportMain = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_main")
  /// Export in 1080P is not supported by this phone model
  public static let eoExportNonsupport1080P = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_nonsupport_1080P")
  /// Export in 4K is not supported by this phone model
  public static let eoExportNonsupport4K = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_nonsupport_4K")
  /// Resolution
  public static let eoExportResolution = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_resolution")
  /// Frame Per Second
  public static let eoExportResolutionFps = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_resolution_fps")
  /// Resolution
  public static let eoExportResolutionRes = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_resolution_res")
  /// Reset
  public static let eoExportResolutionReset = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_resolution_reset")
  /// Save
  public static let eoExportResolutionSave = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_resolution_save")
  /// Save error
  public static let eoExportSaveError = ShortformDemoStrings.tr("EOExportLocalizable", "eo_export_save_error")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension ShortformDemoStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
