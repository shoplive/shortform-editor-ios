//
//  ShopLiveDelegateInternalManager.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 4/1/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

public final class ShopLiveDelegateInternalManager {
    public static let shared = ShopLiveDelegateInternalManager()
    
    private var ShopLiveShortformUploaderMessageDelegateStack: [ShopLiveShortformUploaderMessageDelegate] = []
    
    private let serialQueue = DispatchQueue(label: "com.shoplive.delegateQueue")
    
    
    var reservedUUIDforVideoEditor : String?
    
    
    func insertMessageDelegate(delegate: ShopLiveShortformUploaderMessageDelegate) {
        serialQueue.sync { [weak self] in
            self?.ShopLiveShortformUploaderMessageDelegateStack.append(delegate)
        }
    }
    
    public func getMessageDelegate() -> ShopLiveShortformUploaderMessageDelegate? {
        
        let lastDelegate: ShopLiveShortformUploaderMessageDelegate? = ShopLiveShortformUploaderMessageDelegateStack.last
        
        return lastDelegate
    }
    
    func removeDelegate() {
        serialQueue.sync { [weak self] in
            
            var temp = self?.ShopLiveShortformUploaderMessageDelegateStack ?? []
            
            if !temp.isEmpty {
                temp.removeLast()
            }
            
            self?.ShopLiveShortformUploaderMessageDelegateStack = temp
        }
    }
}
