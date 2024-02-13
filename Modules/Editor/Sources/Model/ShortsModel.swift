//
//  ShortsUploadModel.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation
import ShopLiveSDKCommon
import UIKit

public struct ShortsModel: BaseResponsable, Equatable {
    public var _s: Int?
    public var _e: String?
    public var _d: String?
    
    let shortsId: String?
    let srn: String?
    let startAt, endAt: Int?
    let reference: String?
    let shortsDetail: ShortsDetail?
    let activity: Activity?
    let action, payload: String?
    let cards: [CardModel]?
    let shortsType: String?
    let traceId: String?
    let url: String?
    
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<ShortsModel.CodingKeys> = try decoder.container(keyedBy: ShortsModel.CodingKeys.self)
        do {
            self.shortsId = try container.decodeIfPresent(String.self, forKey: ShortsModel.CodingKeys.shortsId)
        } catch {
            // Check for an integer
            if let intValue = try container.decodeIfPresent(Int.self, forKey: ShortsModel.CodingKeys.shortsId) {
                self.shortsId = String(describing: intValue)
            } else {
                self.shortsId = nil
            }
            
        }
        
        self.srn = try container.decodeIfPresent(String.self, forKey: ShortsModel.CodingKeys.srn)
        
        do {
            self.reference = try container.decodeIfPresent(String.self, forKey: ShortsModel.CodingKeys.reference)
        } catch {
            if let intValue = try container.decodeIfPresent(Int.self, forKey: ShortsModel.CodingKeys.reference) {
                self.reference = String(describing: intValue)
            } else {
                self.reference = nil
            }
        }
        
        self.startAt = try container.decodeIfPresent(Int.self, forKey: ShortsModel.CodingKeys.startAt)
        self.endAt = try container.decodeIfPresent(Int.self, forKey: ShortsModel.CodingKeys.endAt)
        
        self.shortsDetail = try container.decodeIfPresent(ShortsDetail.self, forKey: ShortsModel.CodingKeys.shortsDetail)
        self.activity = try container.decodeIfPresent(Activity.self, forKey: ShortsModel.CodingKeys.activity)
        self.cards = try container.decodeIfPresent([CardModel].self, forKey: ShortsModel.CodingKeys.cards)
        
        self.shortsType = try container.decodeIfPresent(String.self, forKey: ShortsModel.CodingKeys.shortsType)
        
        do {
            self.traceId = try container.decodeIfPresent(String.self, forKey: ShortsModel.CodingKeys.traceId)
        } catch {
            // Check for an integer
            if let intValue = try container.decodeIfPresent(Int.self, forKey: ShortsModel.CodingKeys.traceId) {
                self.traceId = String(describing: intValue)
            } else {
                self.traceId = nil
            }
        }
        
        self.url = try container.decodeIfPresent(String.self, forKey: ShortsModel.CodingKeys.url)
        
        self.payload = try container.decodeIfPresent(String.self, forKey: ShortsModel.CodingKeys.payload)
        
        self.action = try container.decodeIfPresent(String.self, forKey: ShortsModel.CodingKeys.action)
    }
    
    public static func ==(lhs: ShortsModel, rhs: ShortsModel) -> Bool {
         return (lhs.shortsId == rhs.shortsId && lhs.srn == rhs.srn)
    }
    
    public var validate: Bool {
        guard let cards = cards,
              cards.filter({ $0.validate }).count > 0 else {
                  return false
              }
        
        return true
    }
}
