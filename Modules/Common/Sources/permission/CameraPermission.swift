//
//  CameraPermission.swift
//  Shoplive Studio
//
//  Created by ShopLive on 2021/09/27.
//

import AVFoundation
import Combine

final class CameraPermission: Permission, SLResultObservable {
    
    enum Result {
        case permissionStatusChanged(PermissionStatus)
    }
    
    var status: PermissionStatus {
        get {
            updatePermission()
            return self.permissionState
        }
    }

    var resultHandler: ((Result) -> ())?
    private var permissionState: PermissionStatus
    var name: String {
        return "CameraPermission"
    }

    var type: PermissionType = .camera

    init() {
        self.permissionState = .notDetermined
        updatePermission()
    }

    func requestPermission() {
        guard permissionState != .authorized || permissionState != .notSupported else {
            resultHandler?(.permissionStatusChanged(permissionState))
            return
        }
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] in
            guard let self = self else { return }
            self.permissionState = $0 ? .authorized : .denied
            self.resultHandler?(.permissionStatusChanged(self.permissionState))
        })
    }

    func updatePermission() {
        let authorizedStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

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
