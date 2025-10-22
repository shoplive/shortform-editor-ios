//
//  InAppPipDisplayModel.swift
//  ShopLiveSDK
//
//  Created by Tabber on 10/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

struct InAppPipDisplaysModel {
    var badge: InAppPipDisplayModel?
    var textBox: InAppPipDisplayModel?
}

struct InAppPipDisplayModel {
    var type: String
    var active: Bool
    var layout: InAppPipDisplayLayout
    var padding: InAppPipDisplayPadding
    var size: InAppPipDisplaySize?
    var imageUrl: String?
    var text: String?
    var font: InAppPipDisplayFont?
    var box: InAppDisplayBox?
    
    init(
        type: String,
        active: Bool,
        layout: InAppPipDisplayLayout,
        padding: InAppPipDisplayPadding,
        size: InAppPipDisplaySize? = nil,
        imageUrl: String? = nil,
        text: String? = nil,
        font: InAppPipDisplayFont? = nil,
        box: InAppDisplayBox? = nil
    ) {
        self.type = type
        self.active = active
        self.layout = layout
        self.padding = padding
        self.size = size
        self.imageUrl = imageUrl
        self.text = text
        self.font = font
        self.box = box
    }
}

struct InAppPipDisplayLayout {
    var horizontal: String
    var vertical: String
    
    func horizontalToAlignment() -> InAppPipDisplayHorizontalAlignment? {
        switch horizontal {
        case "LEFT": .LEFT
        case "CENTER": .CENTER
        case "RIGHT": .RIGHT
        default: nil
        }
    }
    
    func verticalToAlignment() -> InAppDisplayVerticalAlignment? {
        switch vertical {
        case "TOP": .TOP
        case "CENTER": .CENTER
        case "BOTTOM": .BOTTOM
        default: nil
        }
    }
}

enum InAppPipDisplayHorizontalAlignment {
    case LEFT
    case CENTER
    case RIGHT
}

enum InAppDisplayVerticalAlignment {
    case TOP
    case CENTER
    case BOTTOM
}

struct InAppPipDisplayPadding {
    var horizontal: CGFloat
    var vertical: CGFloat
}

struct InAppPipDisplaySize {
    var width: CGFloat
    var height: CGFloat
    var maxWidth: CGFloat
}

struct InAppPipDisplayFont {
    var size: CGFloat
    var color: String
}

struct InAppDisplayBox {
    var backgroundColor: String
    var borderRadius: CGFloat
    var paddingX: CGFloat
    var paddingY: CGFloat
}


extension InAppPipDisplayModel {
    static func badgeDummy() -> Self {
        .init(
            type: "BADGE",
            active: true,
            layout: .init(
                horizontal: "RIGHT",
                vertical: "TOP"
            ),
            padding: .init(
                horizontal: 8,
                vertical: 8
            ),
            // Badge 에만 있는 필드
            size: .init(
                width: 320,
                height: 180,
                maxWidth: 375
            ),
            imageUrl: "https://dev-image.shoplive.cloud/a1AoDQoZ9MEWRdDQ/baa87f86-1d14-4dce-a2ad-7679c6975de7.svg"
        )
    }
    
    static func textBoxDummy() -> Self {
        .init(
            type: "TEXTBOX",
            active: true,
            layout: .init(
                horizontal: "CENTER",
                vertical: "BOTTOM"
            ),
            padding: .init(
                horizontal: 8,
                vertical: 8
            ),
            // Textbox 에만 있는 필드
            text: "한글몇",
            font: .init(
                size: 14,
                color: "#111827"
            ),
            box: .init(
                backgroundColor: "#FFFFFF",
                borderRadius: 8,
                paddingX: 8,
                paddingY: 6
            )
        )
    }
}
