// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum PlayerDemo2Asset: Sendable {
  public static let accentColor = PlayerDemo2Colors(name: "AccentColor")
  public static let back = PlayerDemo2Images(name: "back")
  public static let checkNotSelected = PlayerDemo2Images(name: "check_not_selected")
  public static let checkSelected = PlayerDemo2Images(name: "check_selected")
  public static let close = PlayerDemo2Images(name: "close")
  public static let downArrow = PlayerDemo2Images(name: "down_arrow")
  public static let icHamburger = PlayerDemo2Images(name: "ic_hamburger")
  public static let loading1 = PlayerDemo2Images(name: "loading1")
  public static let loading10 = PlayerDemo2Images(name: "loading10")
  public static let loading11 = PlayerDemo2Images(name: "loading11")
  public static let loading2 = PlayerDemo2Images(name: "loading2")
  public static let loading3 = PlayerDemo2Images(name: "loading3")
  public static let loading4 = PlayerDemo2Images(name: "loading4")
  public static let loading5 = PlayerDemo2Images(name: "loading5")
  public static let loading6 = PlayerDemo2Images(name: "loading6")
  public static let loading7 = PlayerDemo2Images(name: "loading7")
  public static let loading8 = PlayerDemo2Images(name: "loading8")
  public static let loading9 = PlayerDemo2Images(name: "loading9")
  public static let logoBlack = PlayerDemo2Images(name: "logo_black")
  public static let moreButton = PlayerDemo2Images(name: "more_button")
  public static let radioNotSelected = PlayerDemo2Images(name: "radio_not_selected")
  public static let radioSelected = PlayerDemo2Images(name: "radio_selected")
  public static let snsIcon1 = PlayerDemo2Images(name: "sns_icon_1")
  public static let snsIcon2 = PlayerDemo2Images(name: "sns_icon_2")
  public static let snsIcon3 = PlayerDemo2Images(name: "sns_icon_3")
  public static let snsIcon4 = PlayerDemo2Images(name: "sns_icon_4")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class PlayerDemo2Colors: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  public var color: Color {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIColor: SwiftUI.Color {
      return SwiftUI.Color(asset: self)
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension PlayerDemo2Colors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: PlayerDemo2Colors) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
  init(asset: PlayerDemo2Colors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct PlayerDemo2Images: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: PlayerDemo2Images) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: PlayerDemo2Images, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: PlayerDemo2Images) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:enable all
// swiftformat:enable all
