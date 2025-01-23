//
//  SLQRReaderViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//


import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon


protocol QRKeyReaderDelegate: NSObjectProtocol {
    func updateKeyFromQR(keyset : ShopLiveKeySet?)
    func updateUserJWTFromQR(userJWT: String?)
}


class SLQRReaderViewController: UIViewController {
    weak var delegate: QRKeyReaderDelegate?

    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?

    private var cornerLength: CGFloat = 20
    private var cornerLineWidth: CGFloat = 6
    private var rectOfInterest: CGRect {
        CGRect(x: (self.view.bounds.width / 2) - (200 / 2),
               y: (self.view.bounds.height / 2) - (200 / 2),
                          width: 200, height: 200)
    }
    
    var isRunning: Bool {
        guard let captureSession = self.captureSession else {
            return false
        }
        return captureSession.isRunning
    }
    
    let metadataObjectTypes: [AVMetadataObject.ObjectType] = [.qr]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.startRunning()
        }
    }
    
    private func initialSetupView() {
        self.view.clipsToBounds = true
        self.captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        let videoInput: AVCaptureInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        guard let captureSession = self.captureSession else {
            self.dismiss(animated: true)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            self.dismiss(animated: true)
            return
        }

        
        let metadataOutput = AVCaptureMetadataOutput()
                
        if captureSession.canAddOutput(metadataOutput) {
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureSession.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = self.metadataObjectTypes
            
        } else {
            self.dismiss(animated: true)
            return
        }
                
        self.setPreviewLayer()
        self.setFocusZoneCornerLayer()
        
        
    }
    
    
    private func setPreviewLayer() {
        let readingRect = rectOfInterest
        
        guard let captureSession = self.captureSession else {
            return
        }
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = self.view.layer.bounds

        
        let path = CGMutablePath()
        path.addRect(self.view.bounds)
        path.addRect(readingRect)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        maskLayer.fillRule = .evenOdd

        previewLayer.addSublayer(maskLayer)
        
        
        self.view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
    
    
    private func setFocusZoneCornerLayer() {
        var cornerRadius = previewLayer?.cornerRadius ?? CALayer().cornerRadius
        if cornerRadius > cornerLength { cornerRadius = cornerLength }
        if cornerLength > rectOfInterest.width / 2 { cornerLength = rectOfInterest.width / 2 }

        
        let upperLeftPoint = CGPoint(x: rectOfInterest.minX - cornerLineWidth / 2, y: rectOfInterest.minY - cornerLineWidth / 2)
        let upperRightPoint = CGPoint(x: rectOfInterest.maxX + cornerLineWidth / 2, y: rectOfInterest.minY - cornerLineWidth / 2)
        let lowerRightPoint = CGPoint(x: rectOfInterest.maxX + cornerLineWidth / 2, y: rectOfInterest.maxY + cornerLineWidth / 2)
        let lowerLeftPoint = CGPoint(x: rectOfInterest.minX - cornerLineWidth / 2, y: rectOfInterest.maxY + cornerLineWidth / 2)
        
        
        let upperLeftCorner = UIBezierPath()
        upperLeftCorner.move(to: upperLeftPoint.offsetBy(dx: 0, dy: cornerLength))
        upperLeftCorner.addArc(withCenter: upperLeftPoint.offsetBy(dx: cornerRadius, dy: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: true)
        upperLeftCorner.addLine(to: upperLeftPoint.offsetBy(dx: cornerLength, dy: 0))

        let upperRightCorner = UIBezierPath()
        upperRightCorner.move(to: upperRightPoint.offsetBy(dx: -cornerLength, dy: 0))
        upperRightCorner.addArc(withCenter: upperRightPoint.offsetBy(dx: -cornerRadius, dy: cornerRadius),
                              radius: cornerRadius, startAngle: 3 * .pi / 2, endAngle: 0, clockwise: true)
        upperRightCorner.addLine(to: upperRightPoint.offsetBy(dx: 0, dy: cornerLength))

        let lowerRightCorner = UIBezierPath()
        lowerRightCorner.move(to: lowerRightPoint.offsetBy(dx: 0, dy: -cornerLength))
        lowerRightCorner.addArc(withCenter: lowerRightPoint.offsetBy(dx: -cornerRadius, dy: -cornerRadius),
                                 radius: cornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
        lowerRightCorner.addLine(to: lowerRightPoint.offsetBy(dx: -cornerLength, dy: 0))

        let bottomLeftCorner = UIBezierPath()
        bottomLeftCorner.move(to: lowerLeftPoint.offsetBy(dx: cornerLength, dy: 0))
        bottomLeftCorner.addArc(withCenter: lowerLeftPoint.offsetBy(dx: cornerRadius, dy: -cornerRadius),
                                radius: cornerRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
        bottomLeftCorner.addLine(to: lowerLeftPoint.offsetBy(dx: 0, dy: -cornerLength))
        
        
        let combinedPath = CGMutablePath()
        combinedPath.addPath(upperLeftCorner.cgPath)
        combinedPath.addPath(upperRightCorner.cgPath)
        combinedPath.addPath(lowerRightCorner.cgPath)
        combinedPath.addPath(bottomLeftCorner.cgPath)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = combinedPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = cornerLineWidth
        shapeLayer.lineCap = .square

        self.previewLayer!.addSublayer(shapeLayer)
    }
}

// MARK: - AVCapture Output
extension SLQRReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!){
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else {
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            
            guard let url = URL(string: stringValue) else { return }
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = urlComponents?.queryItems as? [URLQueryItem]
            
            if let userJWT = queryItems?.first(where: { $0.name == "userjwt" })?.value {
                self.dismiss(animated: true, completion: {
                    self.delegate?.updateUserJWTFromQR(userJWT: userJWT)
                })
            } else {
                guard let ak = queryItems?.first(where: {$0.name == "ak"})?.value, let ck = queryItems?.first(where: {$0.name == "ck"})?.value else { return }
                
                let title: String? = queryItems?.first(where: {$0.name == "title"})?.value
                
                self.dismiss(animated: true, completion: {
                    self.delegate?.updateKeyFromQR(keyset: .init(alias: title ?? "Unknown Title (QR)", campaignKey: ck, accessKey: ak))
                })
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else {
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            
            guard let url = URL(string: stringValue) else { return }
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = urlComponents?.queryItems as? [URLQueryItem]
            
            ShopLiveLogger.tempLog(url.absoluteString)
            ShopLiveLogger.tempLog(urlComponents?.query ?? "")
            
            if let userJWT = queryItems?.first(where: { $0.name == "userjwt" })?.value {
                
                self.dismiss(animated: true, completion: {
                    self.delegate?.updateUserJWTFromQR(userJWT: userJWT)
                })
                
            } else {
                guard let ak = queryItems?.first(where: {$0.name == "ak"})?.value, let ck = queryItems?.first(where: {$0.name == "ck"})?.value else { return }
                
                let title: String? = queryItems?.first(where: {$0.name == "title"})?.value
                
                self.dismiss(animated: true, completion: {
                    self.delegate?.updateKeyFromQR(keyset: .init(alias: title ?? "Unknown Title (QR)", campaignKey: ck, accessKey: ak))
                })
            }
            
            

        }
    }
}

internal extension CGPoint {

    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        var point = self
        point.x += dx
        point.y += dy
        return point
    }
}

