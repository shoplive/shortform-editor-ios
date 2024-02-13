//
//  Permission.swift
//  Shoplive Studio
//
//  Created by ShopLive on 2021/10/10.
//

import Foundation
import AVKit

@objc
public enum PermissionType: Int {
    case camera
    case microphone
    case idfa

    var description: String {
        switch self {
        case .camera:
            return "camera"
        case .microphone:
            return "microphone"
        case .idfa:
            return "idfa"
        }
    }
}

@objc
public enum PermissionStatus: Int {
    case authorized
    case denied
    case notDetermined
    case notSupported
    case limited

    var description: String {
        switch self {
        case .authorized:
            return "authorized"
        case .denied:
            return "denied"
        case .notDetermined:
            return "notDetermined"
        case .notSupported:
            return "notSupported"
        case .limited:
            return "limited"
        }
    }
}

public enum PermissionError: Error {
    case denied
    case notSupported

    var localizedDescription: String {
        switch self {
        case .denied:
            return "permission denied"
        case .notSupported:
            return "permission not supported"
        }
    }
}

protocol Permission {
    var type: PermissionType { get set }
    var status: PermissionStatus { get }
    var name: String { get }

    func requestPermission()
    func updatePermission()
}

public final class PermissionManager: SLRequestable, SLResultObservable {
    
    public enum Request {
        case checkEveryPermission
    }
    
    public enum Result {
        case authorizationResult(camera: PermissionStatus, audio: PermissionStatus)
    }
    
    public func request(_ request: Request) {
        switch request {
        case .checkEveryPermission:
            checkPermission()
        }
    }
    
    public init() {
        bindData()
    }

    public var resultHandler: ((Result) -> ())?

    public var deviceAuthorized: Bool {
        return cameraPermission.status == .authorized && microPhonePermission.status == .authorized
    }

    public var deviceChecked: Bool {
        return permissions.filter({ $0.status != .notDetermined }).count == 0
    }
    
    public var cameraAuthorized: Bool {
        return cameraPermission.status == .authorized
    }
    
    public var audioAuthorized: Bool {
        return microPhonePermission.status == .authorized
    }

    private let cameraPermission = CameraPermission()
    private let microPhonePermission = MicroPhonePermission()
    private let dispatchGroup = DispatchGroup()
    
    private var permissions: [Permission] {
        return [cameraPermission, microPhonePermission]
    }
    
    private func checkPermission() {
        let authorizedPermissionCount = permissions
            .filter({ $0.status == .authorized })
            .count
        
        guard authorizedPermissionCount < permissions.count else {
            sendComplete()
            return
        }
        
        let countForNotDetminedPermission = permissions
            .filter({ $0.status == .notDetermined })
            .count

        guard countForNotDetminedPermission > 0 else {
            sendComplete()
            return
        }
        
        permissions
            .filter({ $0.status == .notDetermined })
            .forEach({
                dispatchGroup.enter()
                $0.requestPermission()
            })
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.sendComplete()
        }
    }
    
    private func bindData() {
        cameraPermission.resultHandler = { [weak self] in
            switch $0 {
            case .permissionStatusChanged:
                self?.dispatchGroup.leave()
            }
        }
        
        microPhonePermission.resultHandler = { [weak self] in
            switch $0 {
            case .permissionStatusChanged:
                self?.dispatchGroup.leave()
            }
        }
    }
    
    private func sendComplete() {
        let cameraPermission = cameraPermission.status
        let audioPermission = microPhonePermission.status
        
        guard cameraPermission != .notDetermined && audioPermission != .notDetermined else { return }
        
        resultHandler?(.authorizationResult(camera: cameraPermission, audio: audioPermission))
    }
}
