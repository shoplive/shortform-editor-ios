//
//  DemoSecretKeyTool.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

@objc protocol SecretKeySetObserver {
    var identifier: String { get }
    func setretKeysetUpdated()
    @objc optional func currentSecretKeyUpdated()
}

final class DemoSecretKeyTool {

    private static let saveIdentifier: String = "DemoSecretKeys"
    private static let currentKeyIdentifier: String = "currentSecretKey"

    static let shared: DemoSecretKeyTool = DemoSecretKeyTool()

    private var keys: [DemoSecretKeySet] = []
    private var observers: [SecretKeySetObserver?] = []

    var keysets: [DemoSecretKeySet] {
        loadData()
        return keys
    }

    private func notifyObservers() {
        self.observers.forEach { observer in
            observer?.setretKeysetUpdated()
        }
    }

    private func notifyCurrentKeyObservers() {
        self.observers.forEach { observer in
            observer?.currentSecretKeyUpdated?()
        }
    }

    func addKeysetObserver(observer: SecretKeySetObserver) {
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
        UserDefaults.standard.set(archiveData(keysets: keys), forKey: DemoSecretKeyTool.saveIdentifier)
        UserDefaults.standard.synchronize()
    }

    private func loadData() {
        guard let loadedKeys = unArchiveData() else { return }
        keys.removeAll()
        keys = loadedKeys
        loadCurrentKey()
    }

    private func loadCurrentKey() {
        curKey = UserDefaults.standard.string(forKey: DemoSecretKeyTool.currentKeyIdentifier) ?? ""
    }

    func clearKey() {
        keys.removeAll()
        saveData()
        if self.keys.isEmpty {
            saveCurrentKey(name: "")
        }
        notifyObservers()
    }

    func saveCurrentKey(name: String) {
        curKey = name
        UserDefaults.standard.setValue(curKey, forKey: DemoSecretKeyTool.currentKeyIdentifier)
        notifyCurrentKeyObservers()
    }

    func currentKey() -> DemoSecretKeySet? {
        return load(name: curKey)
    }

    private func remove(name: String) {
        self.keys.removeAll(where: {$0.name == name})
    }

    private func archiveData(keysets : [DemoSecretKeySet]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: keysets, requiringSecureCoding: false)

            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }

    }

    private func unArchiveData() -> [DemoSecretKeySet]? {
        guard
            let unarchivedObject = UserDefaults.standard.data(forKey: DemoSecretKeyTool.saveIdentifier)
        else {
            return nil
        }
        do {
            guard let keysetArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as? [DemoSecretKeySet] else {
                return nil
            }
            return keysetArray
        } catch {
            return nil
        }
    }

    func save(key: DemoSecretKeySet) {
        loadData()
        remove(name: key.name)
        keys.append(key)
        saveData()
        notifyObservers()
    }

    func delete(name: String) {
        remove(name: name)
        saveData()
        if self.keys.isEmpty || curKey == name {
            saveCurrentKey(name: "")
        }
        notifyObservers()
    }

    func load(name: String) -> DemoSecretKeySet? {
        return self.keys.filter({$0.name == name}).first
    }


    func names() -> [String] {
        return self.keys.map { keyset in
            keyset.name
        }
    }

}
