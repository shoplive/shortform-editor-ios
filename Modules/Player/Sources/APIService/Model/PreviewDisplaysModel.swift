//
//  PreviewDisplaysModel.swift
//  ShopLiveSDK
//
//  Created by Tabber on 10/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

struct PreviewDisplaysModel: Codable {
    let badge: PreviewBadgeModel
    let textBox: PreviewTextBoxModel
    
    enum CodingKeys: CodingKey {
        case badge
        case textBox
    }
    
    func toEntity() -> InAppPipDisplaysEntity {
        .init(
            badge: badge.active ? badge.toEntity() : nil,
            textBox: textBox.active ? textBox.toEntity() : nil
        )
    }
}

struct PreviewBadgeModel: Codable {
    let active: Bool
    let imageUrl: String?
    let layout: PreviewLayoutModel
    let size: PreviewSizeModel
    
    func toEntity() -> InAppPipDisplayEntity {
        .init(
            type: "BADGE",
            active: active,
            layout: layout.toAlignmentEntity(),
            padding: layout.toPaddingEntity(),
            size: size.toEntity(),
            imageUrl: imageUrl
        )
    }
}

struct PreviewLayoutModel: Codable {
    let padding: PreviewPaddingModel
    let alignment: PreviewAlignmentModel
    
    func toPaddingEntity() -> InAppPipDisplayPadding {
        .init(
            horizontal: CGFloat(padding.horizontal),
            vertical: CGFloat(padding.vertical)
        )
    }
    
    func toAlignmentEntity() -> InAppPipDisplayLayout {
        .init(
            horizontal: alignment.horizontal,
            vertical: alignment.vertical
        )
    }
}

struct PreviewPaddingModel: Codable {
    let horizontal: Int
    let vertical: Int
}

struct PreviewAlignmentModel: Codable {
    let horizontal: String
    let vertical: String
}

struct PreviewSizeModel: Codable {
    let width: Int
    let height: Int
    let maxWidth: Int
    
    func toEntity() -> InAppPipDisplaySize {
        .init(
            width: CGFloat(width),
            height: CGFloat(height),
            maxWidth: CGFloat(maxWidth)
        )
    }
}

struct PreviewTextBoxModel: Codable {
    let active: Bool
    let text: String?
    let layout: PreviewLayoutModel
    let box: PreviewBoxModel
    let font: PreviewFontModel
    
    func toEntity() -> InAppPipDisplayEntity {
        .init(
            type: "TEXTBOX",
            active: active,
            layout: layout.toAlignmentEntity(),
            padding: layout.toPaddingEntity(),
            size: nil,
            imageUrl: nil,
            text: text,
            font: font.toEntity(),
            box: box.toEntity()
        )
    }
}

struct PreviewBoxModel: Codable {
    let backgroundColor: String
    let borderRadius: Int
    let paddingX: Int
    let paddingY: Int
    
    func toEntity() -> InAppDisplayBox {
        .init(
            backgroundColor: backgroundColor,
            borderRadius: CGFloat(borderRadius),
            paddingX: CGFloat(paddingX),
            paddingY: CGFloat(paddingY)
        )
    }
}

struct PreviewFontModel: Codable {
    let size: Int
    let color: String
    
    func toEntity() -> InAppPipDisplayFont {
        .init(
            size: CGFloat(size),
            color: color
        )
    }
}
