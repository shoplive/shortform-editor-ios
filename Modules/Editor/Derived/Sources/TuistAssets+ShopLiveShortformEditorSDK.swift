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
public enum ShopLiveShortformEditorSDKAsset {
  public static let slArrow = ShopLiveShortformEditorSDKImages(name: "sl_arrow")
  public static let slBackArrow = ShopLiveShortformEditorSDKImages(name: "sl_back_arrow")
  public static let slCamera = ShopLiveShortformEditorSDKImages(name: "sl_camera")
  public static let slCloseButton = ShopLiveShortformEditorSDKImages(name: "sl_close_button")
  public static let slClosebutton = ShopLiveShortformEditorSDKImages(name: "sl_closebutton")
  public static let slEditorHandleLeft = ShopLiveShortformEditorSDKImages(name: "sl_editor_handle_left")
  public static let slEditorHandleRight = ShopLiveShortformEditorSDKImages(name: "sl_editor_handle_right")
  public static let slEditorPlayButton = ShopLiveShortformEditorSDKImages(name: "sl_editor_play_button")
  public static let slIcCrop = ShopLiveShortformEditorSDKImages(name: "sl_ic_crop")
  public static let slIcDownarrow = ShopLiveShortformEditorSDKImages(name: "sl_ic_downarrow")
  public static let slIcEditMute = ShopLiveShortformEditorSDKImages(name: "sl_ic_edit_mute")
  public static let slIcEditUnmute = ShopLiveShortformEditorSDKImages(name: "sl_ic_edit_unmute")
  public static let slIcFilter = ShopLiveShortformEditorSDKImages(name: "sl_ic_filter")
  public static let slIcHotAirBallon = ShopLiveShortformEditorSDKImages(name: "sl_ic_hot_air_ballon")
  public static let slIcMediaFilled = ShopLiveShortformEditorSDKImages(name: "sl_ic_media_filled")
  public static let slIcPerson = ShopLiveShortformEditorSDKImages(name: "sl_ic_person")
  public static let slIcPlay = ShopLiveShortformEditorSDKImages(name: "sl_ic_play")
  public static let slIcShopliveLogo = ShopLiveShortformEditorSDKImages(name: "sl_ic_shoplive_logo")
  public static let slIcSpeedometer = ShopLiveShortformEditorSDKImages(name: "sl_ic_speedometer")
  public static let slInsertPhotoMaterial = ShopLiveShortformEditorSDKImages(name: "sl_insertPhotoMaterial")
  public static let slPlaybar = ShopLiveShortformEditorSDKImages(name: "sl_playbar")
  public static let slPlaypreview = ShopLiveShortformEditorSDKImages(name: "sl_playpreview")
  public static let slPopArrow = ShopLiveShortformEditorSDKImages(name: "sl_pop_arrow")
  public static let slTimeSliderThumb = ShopLiveShortformEditorSDKImages(name: "sl_timeSliderThumb")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ShopLiveShortformEditorSDKImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = ShopLiveShortformEditorSDKResources.bundle
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

public extension ShopLiveShortformEditorSDKImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ShopLiveShortformEditorSDKImages.image property")
  convenience init?(asset: ShopLiveShortformEditorSDKImages) {
    #if os(iOS) || os(tvOS)
    let bundle = ShopLiveShortformEditorSDKResources.bundle
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
  init(asset: ShopLiveShortformEditorSDKImages) {
    let bundle = ShopLiveShortformEditorSDKResources.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ShopLiveShortformEditorSDKImages, label: Text) {
    let bundle = ShopLiveShortformEditorSDKResources.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ShopLiveShortformEditorSDKImages) {
    let bundle = ShopLiveShortformEditorSDKResources.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:enable all
// swiftformat:enable all
