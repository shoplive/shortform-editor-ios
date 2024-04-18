//
//  ShopLiveFFmpegTextView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/26/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit


class ShopLiveFFmpegTextBox : UIView {
    
    private var textView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .init(white: 0.5, alpha: 0.5)
        textView.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        textView.textContainer.lineFragmentPadding = .zero
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.textColor = .black
        textView.textAlignment = .center
        return textView
    }()
    
    private var panGesture : UIPanGestureRecognizer?
    
    private var doubleTapGesture : UITapGestureRecognizer?
    
    private var videoResolution : CGSize = .zero
    
    
    private var coordinateSuperFrame : CGRect?
    private var coordinateSuperView : UIView?
    
    private var timeRange : CMTimeRange?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        self.setKeyboardToolbar()
        self.setPanGestureRecognizer()
    }
    
    required init?(coder : NSCoder) {
        fatalError("")
    }
    
    func setViewHiddenByTimeRange(currentTime : CMTime) {
        guard let timeRange = timeRange else {
            self.isHidden = true
            return
        }
        
        let startTime = timeRange.start
        let endTime = timeRange.end
        
        if currentTime >= startTime && currentTime <= endTime {
            self.isHidden = false
        }
        else {
            self.isHidden = true
        }
    }
}
//MARK: -Getter
extension ShopLiveFFmpegTextBox {
    func getText() -> String {
        return textView.text
    }
    
    func getTextColor() -> String {
        return getHexColor(color: textView.textColor ?? .init(red: 0, green: 0, blue: 0))
    }
    
    func getTextBackgroundColor() -> String {
        return getHexColor(color: textView.backgroundColor ?? .init(red: 0, green: 0, blue: 0))
    }
    
    private func getHexColor(color : UIColor) -> String {
        
        guard let components = color.cgColor.components else {
            return CGEParserUtil.makeRGB2HexString(r: 0, g: 0, b: 0, a: 1)
        }
        
        if components.count == 2 {
            let r: Float = Float(components[0])
            let g: Float = Float(components[0])
            let b: Float = Float(components[0])
            
            let hexString = CGEParserUtil.makeRGB2HexString(r: r, g: g, b: b, a: 1)
            
            return hexString
        }
        else {
            let r: Float = Float(components[0])
            let g: Float = Float(components[1])
            let b: Float = Float(components[2])
            
            let hexString = CGEParserUtil.makeRGB2HexString(r: r, g: g, b: b, a: 1)
            
            return hexString
        }
    }
    
    func getTextFontSize() -> Int {
        return Int(textView.font?.pointSize ?? 13.0)
    }
    
    func getPosition() -> CGRect? {
        guard let superFrame = self.coordinateSuperFrame,
              let coordSuperview = self.coordinateSuperView else { return nil }
        
        let widthRatio = self.videoResolution.width / superFrame.width
        let heightRatio = self.videoResolution.height / superFrame.height
        let newVideoSize: CGSize = CGSize(width: self.bounds.width * widthRatio, height: self.bounds.height * heightRatio)
        let convertedOrigin = self.convert(self.bounds.origin, to: coordSuperview)
        return CGRect(x: convertedOrigin.x * widthRatio, y: convertedOrigin.y * heightRatio, width: newVideoSize.width, height: newVideoSize.height)
    }
    
    func getTimeRange() -> CMTimeRange? {
        return self.timeRange
    }
}
//MARK: -Setter
extension ShopLiveFFmpegTextBox {
    func setText(text : String) {
        self.textView.text = text
    }
    
    func setFontSize(size : Int) {
        self.textView.font = UIFont.systemFont(ofSize: CGFloat(size), weight: .regular)
    }
    
    func setTextColor(color : String) {
        let uiColor = UIColor(color)
        self.textView.textColor = uiColor
    }
    
    func setTextBackgroundColor(color : String) {
        let uiColor = UIColor(color)
        self.textView.backgroundColor = uiColor
    }
    
    func setCoordinateSuperView(superView : UIView) {
        self.coordinateSuperView = superView
    }
    
    func setVideoResolution(resolution : CGSize) {
        self.videoResolution = resolution
    }
    
    func setCoordinateSuperFrame(frame : CGRect) {
        self.coordinateSuperFrame = frame
    }
    
    func setTimeRange(timeRange : CMTimeRange) {
        self.timeRange = timeRange
    }
    
    
}
extension ShopLiveFFmpegTextBox {
    private func setLayout() {
        self.addSubview(textView)
    }
    
    
    private func setKeyboardToolbar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        textView.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        textView.endEditing(true)
    }
}
extension ShopLiveFFmpegTextBox {
    
    private func setPanGestureRecognizer(){
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender: )))
        textView.addGestureRecognizer(panGesture!)
    }
    
    
    @objc private func handlePanGesture(sender : UIPanGestureRecognizer) {
        let view = sender.view
        let translation = sender.translation(in: view)
        
        switch sender.state {
        case .began:
            break
        case .changed:
            let yChange = translation.y
            let xChange = translation.x
            let originCentx = self.center.x
            let originCenty = self.center.y
            
            self.center = .init(x: originCentx + xChange, y: originCenty + yChange)
            
            
            sender.setTranslation(.zero, in: view)
            break
        case .ended:
            break
        default:
            break
        }
    }
}
