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
import Photos

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
            
            self.runFFProbCommand(videoPath: url.absoluteString, completion: { isValidCodec in
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
    
    private func runFFProbCommand(videoPath : String, completion : @escaping(Bool) -> ()){
        let command = "-v quiet -print_format json -show_format -show_streams -i \(videoPath)"
        
        FFprobeKit.executeAsync(command) { [weak self] session in
            guard let session = session,
                  let data = session.getOutput().data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                  let jsonDict = json as? [String : Any],
                  let streams = jsonDict["streams"] as? [[String : Any]] else {
                completion(false)
                return
            }
            for stream in streams {
                if let codecType = stream["codec_type"] as? String, codecType == "video",
                   let codecName = stream["codec_name"] as? String {
                    completion(self?.checkIfCodecIsValid(codecName: codecName) ?? false)
                    return
                }
            }
            completion(false)
        }
    }
    
    private func checkIfCodecIsValid(codecName : String) -> Bool {
        let candidateCodecNames : [String] = ["vid.stab","xvidcore","hevc"]
        if candidateCodecNames.contains(where: { $0 == codecName }) {
            return true
        }
        return extractWordWithEnding264Or265(target: codecName )
    }
    
    private func extractWordWithEnding264Or265(target : String) -> Bool {
        let suffix = target.suffix(3)
        if suffix == "264" || suffix == "265" {
            return true
        }
        return false
    }
    
    private func showSLVideoEditorViewController() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.navigationController?.viewControllers.filter({$0.isKind(of: SLVideoEditorViewController2.self)}).count == 0 else { return }
            guard let video = self.video else { return }
            
            let editor = SLVideoEditorViewController2(video: video)
            editor.delegate = self
            editor.shortformEditorDelegate = self.shortformEditorDelegate
            
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
