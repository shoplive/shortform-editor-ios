//
//  MicroPhonePermission.swift
//  Shoplive Studio
//
//  Created by ShopLive on 2021/09/27.
//

import AVFoundation

final class MicroPhonePermission: Permission, SLResultObservable {
    enum Result {
        case permissionStatusChanged(PermissionStatus)
    }

    var checked: Bool = false
    var resultHandler: ((Result) -> ())?
    var status: PermissionStatus {
        get {
//            ShopLiveLogger.devLog("[status get \(name)] permissions status")
            updatePermission()
            return self.permissionState
        }
    }

    private var permissionState: PermissionStatus

    var name: String {
        return "MicroPhonePermission"
    }

    var type: PermissionType = .camera

    init() {
        self.permissionState = .notDetermined
        updatePermission()
    }

    func requestPermission() {
        guard permissionState != .authorized || permissionState != .notSupported else {
            return
        }
        
        AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { [weak self] in
            guard let self = self else { return }
//            ShopLiveLogger.devLog("[\(self.name)] requestAccess status: \(self.status.description)")
//            ShopLiveLogger.devLog("[requestPermission \(self.name)] permissions status")
            self.permissionState = $0 ? .authorized : .denied
            self.checked = true
            self.resultHandler?(.permissionStatusChanged(self.permissionState))
        })
    }

    func updatePermission() {
        let authorizedStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
//        ShopLiveLogger.devLog("[updatePermission\(name)] permissions status")
        switch (authorizedStatus) {
        case AVAuthorizationStatus.authorized:
            permissionState = .authorized
        case AVAuthorizationStatus.notDetermined:
            permissionState = .notDetermined
        case AVAuthorizationStatus.denied:
            permissionState = .denied
        case AVAuthorizationStatus.restricted:
            permissionState = .notSupported
        default:
            permissionState = .notDetermined
        }
    }
}

