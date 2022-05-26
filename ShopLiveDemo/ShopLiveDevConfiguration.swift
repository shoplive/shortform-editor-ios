//
//  ShopLiveDevConfiguration.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/16.
//

import Foundation
import UIKit

@objc protocol DevConfigurationObserver {
    var identifier: String { get }
    @objc optional func updatedValues(keys: [String])
}

final class ShopLiveDevConfiguration {

    static let shared: ShopLiveDevConfiguration = .init()
    private var observers: [DevConfigurationObserver?] = []

    private func notifyObservers(key: String) {
        self.observers.forEach { observer in
            observer?.updatedValues?(keys: [key])
        }
    }

    func addConfigurationObserver(observer: DevConfigurationObserver) {
        if observers.contains(where: { $0?.identifier == observer.identifier }), let index = observers.firstIndex(where: { $0?.identifier == observer.identifier}) {
            observers.remove(at: index)
        }

        observers.append(observer)
    }

    var useAppLog: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "useAppLog")
            UserDefaults.standard.synchronize()
            notifyObservers(key: "useAppLog")
        }
        get {
            UserDefaults.standard.bool(forKey: "useAppLog")
        }
    }
    
    var useLocalLanding: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "useLocalLanding")
            UserDefaults.standard.synchronize()
            notifyObservers(key: "useLocalLanding")
        }
        get {
            UserDefaults.standard.bool(forKey: "useLocalLanding")
        }
    }

    var useWebLog: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "useWebLog")
            UserDefaults.standard.synchronize()
            notifyObservers(key: "useWebLog")
        }
        get {
            UserDefaults.standard.bool(forKey: "useWebLog")
        }
    }

    var phase: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "playerPhase")
            UserDefaults.standard.synchronize()
            notifyObservers(key: "playerPhase")
        }
        get {
            UserDefaults.standard.string(forKey: "playerPhase") ?? ShopLive.Phase.REAL.name
        }
    }

    var phaseType: ShopLive.Phase {
        let phases: [String: ShopLive.Phase] = [
            ShopLive.Phase.DEV.name: ShopLive.Phase.DEV,
            ShopLive.Phase.STAGE.name: ShopLive.Phase.STAGE,
            ShopLive.Phase.REAL.name: ShopLive.Phase.REAL]
        return phases[phase] ?? .DEV
    }
}
