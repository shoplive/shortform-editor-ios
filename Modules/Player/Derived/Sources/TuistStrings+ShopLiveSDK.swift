// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum ShopLiveSDKStrings {

  public enum Chat {
  /// Please enter a message
    public static let placeholder = ShopLiveSDKStrings.tr("Localizable", "chat.placeholder")

    public enum Send {
    /// Send
      public static let title = ShopLiveSDKStrings.tr("Localizable", "chat.send.title")
    }
  }

  public enum Share {

    public enum Url {

      public enum Empty {
      /// There is no shared URL.
        public static let error = ShopLiveSDKStrings.tr("Localizable", "share.url.empty.error")
        /// If there is no url to share, sharing is not executed even if you click the share button.
        public static let message = ShopLiveSDKStrings.tr("Localizable", "share.url.empty.message")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension ShopLiveSDKStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = ShopLiveSDKResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
