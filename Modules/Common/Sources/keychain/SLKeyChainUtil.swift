//
//  SLKeychainUtil.swift
//  ShopliveStudio
//
//  Created by ShopLive on 2022/04/04.
//

import Foundation
import Security

public final class SLKeyChainUtil {
    
    private static var keychainDatas: [KeychainData] = []
    
    static let service: String =  ""
    
    private static func addKeychain(service: String, account: String) {
        let keychainData = KeychainData(service: service, account: account)
        guard !keychainDatas.contains(where: { $0 == keychainData }) else { return }
        
        keychainDatas.append(keychainData)
    }
    
    private static func removeKeychain(service: String, account: String) {
        let keychainData = KeychainData(service: service, account: account)
        guard let index = keychainDatas.firstIndex(where: { $0 == keychainData }) else { return }
        keychainDatas.remove(at: index)
    }
    
    public static func save(keychainData: KeychainData, value: String) {
        save(service: keychainData.service, account: keychainData.account, value: value)
    }
    
    public static func save(service: String, account: String, value: String) {
        
        addKeychain(service: service, account: account)
        
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
        ]
        
        SecItemDelete(keyChainQuery)
        SecItemAdd(keyChainQuery, nil)
    }
    
    public static func load(keychainData: KeychainData) -> String? {
        load(service: keychainData.service, account: keychainData.account)
    }
    
    public static func load(service: String, account: String) -> String? {
        let keyChainQuery :NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)

        if (status == errSecSuccess) {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: .utf8)
            return value
        } else{
            return nil
        }
    }
    
    public static func delete(service: String, account: String) {
        
        removeKeychain(service: service, account: account)
        
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        
        _ = SecItemDelete(keyChainQuery)
    }
    
    public static func resetKeychain() {
        keychainDatas.forEach { keychainData in
            SLKeyChainUtil.delete(service: keychainData.service, account: keychainData.account)
        }
    }
}
