//
//  AVCaptureDevice.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/24/22.
//

import AVKit

public extension AVCaptureDevice {
    var baseZoomFactor_SL: CGFloat {
        var factor: CGFloat = 1.0
        if #available(iOS 13.0, *), self.isVirtualDevice == true {
            //Set initial zoom matching primary (wide angle) camera
            let subDevices = self.constituentDevices
            if subDevices.count <= 1 { return 1.0 }
            let mainCameraIndex = subDevices.firstIndex { $0.deviceType == .builtInWideAngleCamera }
            guard let index = mainCameraIndex, index > 0 else { return 1.0 }
            let zoom = self.virtualDeviceSwitchOverVideoZoomFactors[index - 1]
            let fZoom = CGFloat(truncating: zoom)
            factor = fZoom
        }
        
        return factor
    }
    
    func getInitZoomFactor_SL(forDevice camera: AVCaptureDevice) -> CGFloat {
        var factor: CGFloat = 1.0
        if #available(iOS 13.0, *) {
            if camera.isVirtualDevice == true {
                //Set initial zoom matching primary (wide angle) camera
                let subDevices = camera.constituentDevices
                if subDevices.count <= 1 { return 1.0 }
                let mainCameraIndex = subDevices.firstIndex { $0.deviceType == .builtInWideAngleCamera }
                guard let index = mainCameraIndex, index > 0 else { return 1.0 }
                let zoom = camera.virtualDeviceSwitchOverVideoZoomFactors[index - 1]
                let fZoom = CGFloat(truncating: zoom)
                factor = fZoom
            }
        }
        return factor
    }
}

