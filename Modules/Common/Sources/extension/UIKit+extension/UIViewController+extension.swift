//
//  UIViewController+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/26/22.
//

import UIKit

public extension UIViewController {
    func transition_SL(with window: UIWindow) {
        window.rootViewController = self
        UIView.transition(with: window, duration: 0.3, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {})
    }
    
    @objc open func shopliveHideKeyboard_SL()
    {
        view.endEditing(true)
    }
    
    func hideKeyboard_SL()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.shopliveHideKeyboard_SL))

        view.addGestureRecognizer(tap)
    }
    
    func showShareSheet_SL(url: String?) {
        guard let urlString = url, !urlString.isEmpty else {
            return
        }
                
        guard let shareUrl = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return
        }

        let shareAll:[Any] = [shareUrl]
        let activityViewController = UIActivityViewController(activityItems: shareAll , applicationActivities: nil)
        let popoverController = activityViewController.popoverPresentationController
        popoverController?.sourceView = self.view
        if UIDevice.isIpad_SL {
            popoverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController?.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func didChangeOrientation_SL() -> UIInterfaceOrientationMask {
        if #available(iOS 13, *) {
            if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
                return orientation.isPortrait ? .portrait : .landscape
            }
            else {
                return UIDevice.current.orientation.isPortrait ? .portrait : .landscape
            }
        }
        else {
            return UIApplication.shared.statusBarOrientation.isPortrait ? .portrait : .landscape
        }
    }
}
