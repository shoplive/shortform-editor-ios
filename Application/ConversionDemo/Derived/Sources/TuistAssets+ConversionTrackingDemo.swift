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
public enum ConversionTrackingDemoAsset {
  public static let accentColor = ConversionTrackingDemoColors(name: "AccentColor")
  public static let back = ConversionTrackingDemoImages(name: "back")
  public static let checkNotSelected = ConversionTrackingDemoImages(name: "check_not_selected")
  public static let checkSelected = ConversionTrackingDemoImages(name: "check_selected")
  public static let close = ConversionTrackingDemoImages(name: "close")
  public static let downArrow = ConversionTrackingDemoImages(name: "down_arrow")
  public static let icHamburger = ConversionTrackingDemoImages(name: "ic_hamburger")
  public static let loading1 = ConversionTrackingDemoImages(name: "loading1")
  public static let loading10 = ConversionTrackingDemoImages(name: "loading10")
  public static let loading11 = ConversionTrackingDemoImages(name: "loading11")
  public static let loading2 = ConversionTrackingDemoImages(name: "loading2")
  public static let loading3 = ConversionTrackingDemoImages(name: "loading3")
  public static let loading4 = ConversionTrackingDemoImages(name: "loading4")
  public static let loading5 = ConversionTrackingDemoImages(name: "loading5")
  public static let loading6 = ConversionTrackingDemoImages(name: "loading6")
  public static let loading7 = ConversionTrackingDemoImages(name: "loading7")
  public static let loading8 = ConversionTrackingDemoImages(name: "loading8")
  public static let loading9 = ConversionTrackingDemoImages(name: "loading9")
  public static let logoBlack = ConversionTrackingDemoImages(name: "logo_black")
  public static let moreButton = ConversionTrackingDemoImages(name: "more_button")
  public static let radioNotSelected = ConversionTrackingDemoImages(name: "radio_not_selected")
  public static let radioSelected = ConversionTrackingDemoImages(name: "radio_selected")
  public static let snsIcon1 = ConversionTrackingDemoImages(name: "sns_icon_1")
  public static let snsIcon2 = ConversionTrackingDemoImages(name: "sns_icon_2")
  public static let snsIcon3 = ConversionTrackingDemoImages(name: "sns_icon_3")
  public static let snsIcon4 = ConversionTrackingDemoImages(name: "sns_icon_4")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ConversionTrackingDemoColors {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if canImport(SwiftUI)
  private var _swiftUIColor: Any? = nil
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public private(set) var swiftUIColor: SwiftUI.Color {
    get {
      if self._swiftUIColor == nil {
        self._swiftUIColor = SwiftUI.Color(asset: self)
      }

      return self._swiftUIColor as! SwiftUI.Color
    }
    set {
      self._swiftUIColor = newValue
    }
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ConversionTrackingDemoColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ConversionTrackingDemoColors) {
    let bundle = ConversionTrackingDemoResources.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Color {
  init(asset: ConversionTrackingDemoColors) {
    let bundle = ConversionTrackingDemoResources.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct ConversionTrackingDemoImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = ConversionTrackingDemoResources.bundle
    #if os(iOS) || os(tvOS)
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
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

public extension ConversionTrackingDemoImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ConversionTrackingDemoImages.image property")
  convenience init?(asset: ConversionTrackingDemoImages) {
    #if os(iOS) || os(tvOS)
    let bundle = ConversionTrackingDemoResources.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
  init(asset: ConversionTrackingDemoImages) {
    let bundle = ConversionTrackingDemoResources.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ConversionTrackingDemoImages, label: Text) {
    let bundle = ConversionTrackingDemoResources.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ConversionTrackingDemoImages) {
    let bundle = ConversionTrackingDemoResources.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:enable all
// swiftformat:enable all
