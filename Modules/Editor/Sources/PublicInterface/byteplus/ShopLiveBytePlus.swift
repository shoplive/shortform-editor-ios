//
//  ShopLiveBytePlus.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/27/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import EffectOneKit
import UIKit


public protocol ShopLiveBytePlusDelegate : NSObjectProtocol {
    func videoEditorViewControllerTapNext(_ exportModel: EOExportModel, presentVC viewController: UIViewController)
}


public class ShopLiveBytePlus : NSObject {
    public static let shared = ShopLiveBytePlus()
    public override init() {
        
    }
    
    static private weak var delegate : ShopLiveBytePlusDelegate?
    
    
    private weak var recorderVC : UIViewController?
    private weak var parentVC : UIViewController?
    
    
    public func start(vc : UIViewController,delegate : ShopLiveBytePlusDelegate) {
        self.parentVC = vc
        Self.delegate = delegate
        ShopLiveEOAuthMaker.shared.makeAuth {
            DispatchQueue.main.async {
                let config = EORecorderConfig { initializer in}
                
                EORecorderViewController.startRecorder(with: config, presenter: vc, delegate: self) { [weak self] error in
                    
                }
            }
        }
    }
    
     func showEditorViewController(info: EORecordInfo, presenter: UIViewController) {
    
        // {zh} 构造编辑组件默认配置 {en} Construct editing component default configuration
        let config = EOEditorConfig { initializer in}
        // {zh} 设置编辑组件需要的输入参数 {en} Set the input parameters required by the editing component
        let sceneConfig = EOEditorSceneConfig()
        sceneConfig.resources = info.mediaAssets
        sceneConfig.backgroundMusic = info.backgroundMusic
        sceneConfig.coverImage = info.coverImage
        sceneConfig.previewContentMode = info.source == .camera ? .aspectFill : .aspectFit
        // {zh} 显示编辑页面 {en} Show edit page
        EOVideoEditorViewController.startEditor(with: config, sceneConfig: sceneConfig, presenter: presenter, delegate: self) { [weak self, weak presenter] error in
        };
    }
    
    
}
extension ShopLiveBytePlus : EORecorderViewControllerDelegate {
    public func recorderViewControllerDidTapAlbum(_ recorderViewController: EORecorderViewController) {
        self.recorderVC = recorderViewController
        
        guard let resourcePicker = EOInjectContainer.shared().resourcePickerSharedImpl else {
            return
        }
        
        resourcePicker.pickResourcesFromRecorder { [weak self] resources, error, cancel in
            guard !resources.isEmpty else {
                return;
            }
            
            let info = EORecordInfo()
            info.mediaAssets = resources
            info.source = .album
            // {zh} 完成选图后显示编辑页面 {en} Show the edit page after completing the selection
//            guard let parent = self?.recorderVC?.parent else {
//                ShopLiveLogger.debugLog("[HASSAN LOG] no parent")
//                return
//            }
            
            guard let parent = self?.parentVC else { return }
            guard let presenter = parent.topMostViewController() else {
                return
            }
            self?.showEditorViewController(info: info, presenter: presenter)
        }
    }
    
    public func recorderViewController(_ recorderViewController: EORecorderViewController, didFinishRecordingMediaWith info: EORecordInfo) {
        // {zh} 暂存拍摄组件的应用，用于退出编辑组件时，隐藏相册选图页面 {en} The application that temporarily stores the shooting component is used to hide the album selection page when exiting the editing component
        self.recorderVC = recorderViewController
        // {zh} 进入基础编辑 {en} Enter basic editing
        self.showEditorViewController(info: info, presenter: recorderViewController)
    }
    
    
}
extension ShopLiveBytePlus : EOVideoEditorViewControllerDelegate {
    public func videoEditorViewControllerDidCancel(_ videoEditorViewController: EOVideoEditorViewController) {
        if let recorder = recorderVC {
            // {zh} 隐藏相册选图页面 {en} Hide album selection page
            recorder.dismiss(animated: true, completion: nil)
        } else {
            // {zh} 当从草稿进入编辑页面再退出编辑时，隐藏编辑页面 {en} Hide the edit page when entering the edit page from the draft and then exiting the edit
            videoEditorViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    // {zh} 点击下一步按钮，启动导出页面 {en} Click the Next button to launch the export page
    public func videoEditorViewControllerTapNext(_ exportModel: EOExportModel, presentVC viewController: UIViewController) {
        Self.delegate?.videoEditorViewControllerTapNext(exportModel, presentVC: viewController)
    }
}
fileprivate extension UIViewController {
    func topMostViewController() -> UIViewController? {
        var topViewController: UIViewController?
        let window = UIApplication.shared.keyWindow
        let rootViewController = window?.rootViewController
        if let tabBar = rootViewController as? UITabBarController {
            topViewController = tabBar.selectedViewController
        } else {
            topViewController = rootViewController;
        }
        if let nav = topViewController as? UINavigationController {
            topViewController = nav.topViewController
        }
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
            if let nav = topViewController as? UINavigationController {
                topViewController = nav.topViewController
            }
        }
        return topViewController
    }
}
