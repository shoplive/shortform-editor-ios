//
//  QRReaderViewController.swift
//  ShopLiveSDK
//
//  Created by Vincent on 2022/10/16.
//

import UIKit
import QRScanner
import AVFoundation


class QRReaderViewController: UIViewController {

    weak var delegate: QRKeyReaderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupQRScanner()
    }
    
    private func setupQRScanner() {
       switch AVCaptureDevice.authorizationStatus(for: .video) {
       case .authorized:
           setupQRScannerView()
       case .notDetermined:
           AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
               if granted {
                   DispatchQueue.main.async { [weak self] in
                       self?.setupQRScannerView()
                   }
               }
           }
       default:
           showAlert()
       }
   }
    
    private func setupQRScannerView() {
            let qrScannerView = QRScannerView(frame: view.bounds)
            view.addSubview(qrScannerView)
            qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
            qrScannerView.startRunning()
        }

    private func showAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QRReaderViewController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
            print(error)
        self.dismiss(animated: true)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        print(code)
        guard let url = URL(string: code) else { return }
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = urlComponents?.queryItems as? [URLQueryItem]
        
        guard let ak = queryItems?.first(where: {$0.name == "ak"})?.value, let ck = queryItems?.first(where: {$0.name == "ck"})?.value else { return }
        
        let title: String? = queryItems?.first(where: {$0.name == "title"})?.value
        
        self.dismiss(animated: true, completion: {
            self.delegate?.updateKeyFromQR(keyset: .init(alias: title ?? "Unknown Title (QR)", campaignKey: ck, accessKey: ak))
        })
    }
}
