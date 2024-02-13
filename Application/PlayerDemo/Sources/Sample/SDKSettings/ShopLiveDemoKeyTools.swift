//
//  ShopLiveDemoKeyTools.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/06/09.
//

import Foundation

@objc protocol KeySetObserver {
    var identifier: String { get }
    func keysetUpdated()
    @objc optional func currentKeyUpdated()
}

final class ShopLiveDemoKeyTools {

    private static let saveIdentifier: String = "ShopLiveDemoKeys"
    private static let currentKeyIdentifier: String = "currentKey"

    static let shared: ShopLiveDemoKeyTools = ShopLiveDemoKeyTools()

    private var keys: [ShopLiveKeySet] = []
    private var observers: [KeySetObserver?] = []

    var keysets: [ShopLiveKeySet] {
        loadData()
        return keys.reversed()
    }

    private func notifyObservers() {
        self.observers.forEach { observer in
            observer?.keysetUpdated()
        }
    }

    private func notifyCurrentKeyObservers() {
        self.observers.forEach { observer in
            observer?.currentKeyUpdated?()
        }
    }

    func addKeysetObserver(observer: KeySetObserver) {
        if observers.contains(where: { $0?.identifier == observer.identifier }), let index = observers.firstIndex(where: { $0?.identifier == observer.identifier}) {
            observers.remove(at: index)
        }

        observers.append(observer)
    }

    private var curKey: String = ""

    private init() {
        loadData()
    }

    private func saveData() {
        UserDefaults.standard.set(archiveData(keysets: keys), forKey: ShopLiveDemoKeyTools.saveIdentifier)
        UserDefaults.standard.synchronize()
    }

    private func loadData() {
        guard let loadedKeys = unArchiveData() else { return }
        keys.removeAll()
        keys = loadedKeys
        loadCurrentKey()
    }

    private func loadCurrentKey() {
        curKey = UserDefaults.standard.string(forKey: ShopLiveDemoKeyTools.currentKeyIdentifier) ?? ""
    }

    func clearKey() {
        keys.removeAll()
        saveData()
        if self.keys.isEmpty {
            saveCurrentKey(alias: "")
        }
        notifyObservers()
    }

    func saveCurrentKey(alias: String) {
        curKey = alias
        UserDefaults.standard.setValue(curKey, forKey: ShopLiveDemoKeyTools.currentKeyIdentifier)
        notifyCurrentKeyObservers()
    }

    func currentKey() -> ShopLiveKeySet? {
        return load(alias: curKey)
    }

    private func remove(alias: String) {
        self.keys.removeAll(where: {$0.alias == alias})
    }

    private func archiveData(keysets : [ShopLiveKeySet]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: keysets, requiringSecureCoding: false)

            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }

    }

    private func unArchiveData() -> [ShopLiveKeySet]? {
        guard
            let unarchivedObject = UserDefaults.standard.data(forKey: ShopLiveDemoKeyTools.saveIdentifier)
        else {
            return nil
        }
        do {
            guard let keysetArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as? [ShopLiveKeySet] else {
                return nil
            }
            return keysetArray
        } catch {
            return nil
        }
    }

    func save(key: ShopLiveKeySet) {
        loadData()
        remove(alias: key.alias)
        keys.append(key)
        saveData()
        notifyObservers()
    }

    func delete(alias: String) {
        remove(alias: alias)
        saveData()
        if self.keys.isEmpty || curKey == alias {
            saveCurrentKey(alias: "")
        }
        notifyCurrentKeyObservers()
    }

    func load(alias: String) -> ShopLiveKeySet? {
        return self.keys.filter({$0.alias == alias}).first
    }


    func alias() -> [String] {
        return self.keys.map { keyset in
            keyset.alias
        }
    }

}
