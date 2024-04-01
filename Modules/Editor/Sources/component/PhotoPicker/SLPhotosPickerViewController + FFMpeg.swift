//
//  SLPhotosPickerViewController + FFMpeg.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/6/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ffmpegkit

extension SLPhotosPickerViewController {
    func singleSelected() {
        let phAsset = self.selectedAssets.compactMap{ $0.phAsset }.first
        
        guard let duration = phAsset?.duration, duration >= 0.1 else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dismissPicker(completion: nil)
                let bundle = Bundle(for: type(of: self))
                self.showToast(message: "picker.warning.duration.min.title".localizedString(bundle: bundle))
            }
            return
        }
        
        self.startLoading()
        
        phAsset?.getURL_SL { [weak self] assetsUrl in
            guard let self = self,
                  let url = assetsUrl else { return }
            
            SLCodecValidator.runFFProbCommand(videoPath: url.absoluteString, completion: { isValidCodec in
                if isValidCodec {
                    self.video = ShortsVideo(videoUrl: url)
                    self.finishLoading()
                    self.showSLVideoEditorViewController()
                }
                else {
                    DispatchQueue.main.async {
                        self.finishLoading()
                        let bundle = Bundle(for: type(of: self))
                        self.showToast(message: "toast.codec.notvalid".localizedString(bundle: bundle), duration: .long)
                    }
                }
            })
        }
    }
    
    private func showSLVideoEditorViewController() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.navigationController?.viewControllers.filter({$0.isKind(of: SLVideoEditorViewController2.self)}).count == 0 else { return }
            guard let video = self.video else { return }
            
            let editor = SLVideoEditorViewController2(video: video)
            editor.delegate = self
            editor.shortformEditorDelegate = self.shortformEditorDelegate
            editor.videoEditorDelegate = self.videoEditorDelegate
            
            if self.isSelectedFromCamera {
                self.dismissPicker {
                    self.navigationController?.pushViewController(editor, animated: true)
                }
            }
            else {
                self.navigationController?.pushViewController(editor, animated: true)
            }
        }
    }
    
}
