//
//  SLVideoEditorPlayerCropView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/25/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

enum SLVideoCropHandlePosition {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

protocol SLVideoEditorPlayerCropViewDelegate: AnyObject {
    func updateCropRect(frame: CGRect)
}

class SLVideoEditorPlayerCropHandle: UIView {
    var handlePosition: SLVideoCropHandlePosition = .topLeft
    
    init(handlePosition: SLVideoCropHandlePosition) {
        super.init(frame: .zero)
        self.handlePosition = handlePosition
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        
        let touchArea = bounds.insetBy(dx: -20, dy: -20)
        return touchArea.contains(point)
    }
}

class SLVideoCropMoveView: UIView {}

class SLVideoEditorPlayerCropView: UIView, UIGestureRecognizerDelegate {
    
    typealias FixedInfoType = (fixedPoint: CGPoint, fixedPosition: SLVideoCropHandlePosition)
    
    private var cropRect: CGRect = .zero
    
    weak var delegate: SLVideoEditorPlayerCropViewDelegate?
    
    lazy private var gridView : SLCropInnerGridView = {
        let view = SLCropInnerGridView()
        view.alpha = 0
        self.addSubviews_SL(view)
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawCropView()
        gridView.frame = cropRect
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLVideoEditorCropView deinited")
    }
    
    private lazy var leftTopHandle: SLVideoEditorPlayerCropHandle = {
        let view = SLVideoEditorPlayerCropHandle(handlePosition: .topLeft)
        return view
    }()
    
    private lazy var rightTopHandle: SLVideoEditorPlayerCropHandle = {
        let view = SLVideoEditorPlayerCropHandle(handlePosition: .topRight)
        return view
    }()
    
    private lazy var leftBottomHandle: SLVideoEditorPlayerCropHandle = {
        let view = SLVideoEditorPlayerCropHandle(handlePosition: .bottomLeft)
        return view
    }()
    
    private lazy var rightBottomHandle: SLVideoEditorPlayerCropHandle = {
        let view = SLVideoEditorPlayerCropHandle(handlePosition: .bottomRight)
        return view
    }()
    
    private lazy var backMoveHandle: SLVideoCropMoveView = {
        let view = SLVideoCropMoveView()
        view.backgroundColor = .clear
        return view
    }()
    
    private func layout() {
        self.addSubview(leftTopHandle)
        self.addSubview(rightTopHandle)
        self.addSubview(leftBottomHandle)
        self.addSubview(rightBottomHandle)
        self.addSubview(backMoveHandle)
        self.sendSubviewToBack(backMoveHandle)
        
        let leftTopPangesture = UIPanGestureRecognizer(target: self, action: #selector(handlePangesture))
        let rightTopPangesture = UIPanGestureRecognizer(target: self, action: #selector(handlePangesture))
        let leftBottomPangesture = UIPanGestureRecognizer(target: self, action: #selector(handlePangesture))
        let rightBottomPangesture = UIPanGestureRecognizer(target: self, action: #selector(handlePangesture))
        
        leftTopHandle.addGestureRecognizer(leftTopPangesture)
        rightTopHandle.addGestureRecognizer(rightTopPangesture)
        leftBottomHandle.addGestureRecognizer(leftBottomPangesture)
        rightBottomHandle.addGestureRecognizer(rightBottomPangesture)
        
        let backMovePangesture = UIPanGestureRecognizer(target: self, action: #selector(handleCropMoveGesture))
        backMoveHandle.addGestureRecognizer(backMovePangesture)
        backMovePangesture.delegate = self
        backMovePangesture.isEnabled = true
        backMovePangesture.minimumNumberOfTouches = 1
        backMovePangesture.maximumNumberOfTouches = 1
        
        leftTopPangesture.delegate = self
        leftTopPangesture.isEnabled = true
        leftTopPangesture.minimumNumberOfTouches = 1
        leftTopPangesture.maximumNumberOfTouches = 1
        
        rightTopPangesture.delegate = self
        rightTopPangesture.isEnabled = true
        rightTopPangesture.minimumNumberOfTouches = 1
        rightTopPangesture.maximumNumberOfTouches = 1
        
        leftBottomPangesture.delegate = self
        leftBottomPangesture.isEnabled = true
        leftBottomPangesture.minimumNumberOfTouches = 1
        leftBottomPangesture.maximumNumberOfTouches = 1
        
        rightBottomPangesture.delegate = self
        rightBottomPangesture.isEnabled = true
        rightBottomPangesture.minimumNumberOfTouches = 1
        rightBottomPangesture.maximumNumberOfTouches = 1
    }
    
    var handleInitializePosition: CGPoint = .zero
    var videoResolution: CGSize = .zero
    var cropResolution: CGSize = CGSize(width: 9, height: 16)
    
    private func getFixedInfo(handlePostion: SLVideoCropHandlePosition) -> FixedInfoType {
        var fixPoint: CGPoint = .zero
        var fixPosition: SLVideoCropHandlePosition = .topLeft
        switch handlePostion {
        case .topLeft:
            fixPoint = CGPoint(x: cropRect.origin.x + cropRect.width, y: cropRect.origin.y + cropRect.height)
            fixPosition = .bottomRight
        case .topRight:
            fixPoint = CGPoint(x: cropRect.origin.x, y: cropRect.origin.y + cropRect.height)
            fixPosition = .bottomLeft
        case .bottomLeft:
            fixPoint = CGPoint(x: cropRect.origin.x + cropRect.width, y: cropRect.origin.y)
            fixPosition = .topRight
        case .bottomRight:
            fixPoint = CGPoint(x: cropRect.origin.x, y: cropRect.origin.y)
            fixPosition = .topLeft
        }
        
        return (fixPoint, fixPosition)
    }
    
    @objc func handleCropMoveGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view as? SLVideoCropMoveView else { return }
        
        let translation = recognizer.translation(in: view)
        
        switch recognizer.state {
        case .began:
            gridView.alpha = 1
            break
        case .changed:
            let yChange = translation.y
            let xChange = translation.x
            
            var cropOrigin: CGPoint = CGPoint(x: cropRect.origin.x + xChange, y: cropRect.origin.y + yChange)
            if cropOrigin.x < 0 {
                 cropOrigin.x = 0
             }
             
             if cropOrigin.x + cropRect.width > self.bounds.width {
                 cropOrigin.x = self.bounds.width - cropRect.width
             }
             
             if cropOrigin.y < 0 {
                 cropOrigin.y = 0
             }
             
             if cropOrigin.y + cropRect.height > self.bounds.height {
                 cropOrigin.y = self.bounds.height - cropRect.height
             }
            
            cropRect.origin = cropOrigin
            
            updateHandleViews()
            gridView.frame = cropRect
            drawCropView()

            recognizer.setTranslation(.zero, in: view)
            break
        case .ended:
            gridView.alpha = 0
            delegate?.updateCropRect(frame: self.getCropRect())
            break
        default:
            break
        }
    }
    
    func isAllowSizeCropRect(_ standardRect: CGRect) -> Bool {
        if let config = ShopLiveShortformEditorConfigurationManager.shared.shortformUploadConfiguration {
            if config.videoCropOption.isFixed {
                let h = config.videoCropOption.height
                let w = config.videoCropOption.width
                if w < h {
                    guard standardRect.width >= handleSize * 3 else { return false }
                }
                else {
                    guard standardRect.height >= handleSize * 3 else { return false }
                }
            }
            else {
                guard standardRect.height >= handleSize * 3 && standardRect.width >= handleSize * 3 else { return false }
            }

        }
        else {
            guard standardRect.height >= handleSize * 3 else { return false }
        }
        return true
    }
    
    func newCropRect(point: CGPoint, fixedInfo: FixedInfoType) -> CGRect {
        // direction
        var standardRect: CGRect = .zero
        var width: CGFloat = .zero
        var height: CGFloat = .zero
        let curPoint = point
        
        
        if let config = ShopLiveShortformEditorConfigurationManager.shared.shortformUploadConfiguration {
            if config.videoCropOption.isFixed {
                let h = config.videoCropOption.height
                let w = config.videoCropOption.width
                
                let videoRatio : CGFloat = CGFloat( w ) / CGFloat( h )
                switch panDirection {
                case .up, .down:
                    height = (curPoint.y - fixedInfo.fixedPoint.y).magnitude
                    width = (videoRatio) * height
                    break
                case .left, .right:
                    width = (curPoint.x - fixedInfo.fixedPoint.x).magnitude
                    height = ( 1 / videoRatio ) * width
                    break
                }
            }
            else {
                height = (curPoint.y - fixedInfo.fixedPoint.y).magnitude
                width = (curPoint.x - fixedInfo.fixedPoint.x).magnitude
            }
        }
        else {
            
            switch panDirection {
            case .up, .down:
                height = (curPoint.y - fixedInfo.fixedPoint.y).magnitude
                width = (CGFloat(9)/CGFloat(16)) * height
                break
            case .left, .right:
                width = (curPoint.x - fixedInfo.fixedPoint.x).magnitude
                height = (CGFloat(16)/CGFloat(9)) * width
                break
            }
        }
        
        standardRect.size = CGSize(width: width, height: height)
        
        switch fixedInfo.fixedPosition {
        case .bottomLeft:
            standardRect.origin = CGPoint(x: fixedInfo.fixedPoint.x, y: fixedInfo.fixedPoint.y - height)
            break
        case .bottomRight:
            standardRect.origin = CGPoint(x: fixedInfo.fixedPoint.x - width, y: fixedInfo.fixedPoint.y - height)
            break
        case .topLeft:
            standardRect.origin = CGPoint(x: fixedInfo.fixedPoint.x, y: fixedInfo.fixedPoint.y)
            break
        case .topRight:
            standardRect.origin = CGPoint(x: fixedInfo.fixedPoint.x - width, y: fixedInfo.fixedPoint.y)
            break
        }
        
        guard isAllowSizeCropRect(standardRect) else { return cropRect }
        
        guard standardRect.origin.x >= 0 && standardRect.origin.x + standardRect.width <= self.bounds.width && standardRect.origin.y >= 0 && standardRect.origin.y + standardRect.height <= self.bounds.height else { return cropRect }
        
        return standardRect
    }
    
    
    private func getMoveOrigin(handle: SLVideoEditorPlayerCropHandle, xChange: CGFloat, yChange: CGFloat) -> CGPoint {
        
        var moveOrigin = cropRect.origin
        moveOrigin = CGPoint(x: moveOrigin.x + xChange, y: moveOrigin.y + yChange)
        
        switch handle.handlePosition {
        case .bottomLeft:
            moveOrigin.y += cropRect.height
            break
        case .bottomRight:
            moveOrigin.x += cropRect.width
            moveOrigin.y += cropRect.height
            break
        case.topLeft:
            
            break
        case.topRight:
            moveOrigin.x += cropRect.width
            break
        }
        
        return moveOrigin
    }
    
    var panDirection: PanDirection = .left
    @objc func handlePangesture(_ recognizer: UIPanGestureRecognizer) {
        
        guard let handle = recognizer.view as? SLVideoEditorPlayerCropHandle else { return }
        
        let translation = recognizer.translation(in: handle)
        
        guard let direction = recognizer.direction else { return }
        panDirection = direction
        
        switch recognizer.state {
        case .began:
            gridView.alpha = 1
            break
        case .changed:
            let xChange = translation.x
            let yChange = translation.y
            
            let moveOrigin = getMoveOrigin(handle: handle, xChange: xChange, yChange: yChange)
            
            let fixedInfo = getFixedInfo(handlePostion: handle.handlePosition)
            self.cropRect = newCropRect(point: moveOrigin, fixedInfo: fixedInfo)

            updateHandleViews()
            drawCropView()
            
            
            recognizer.setTranslation(.zero, in: handle)
            break
        case .ended:
            gridView.alpha = 0
            delegate?.updateCropRect(frame: self.getCropRect())
            break
        default:
            break
        }
    }
    
    private let handleSize: CGFloat = 30
    private let handleTapSize: CGFloat = 50
    func updateHandleViews() {
        self.leftTopHandle.frame = CGRect(x: cropRect.origin.x - (handleTapSize / 2), y: cropRect.origin.y - (handleTapSize / 2), width: handleTapSize, height: handleTapSize)
        self.rightTopHandle.frame = CGRect(x: cropRect.origin.x - (handleTapSize / 2) + cropRect.size.width, y: cropRect.origin.y - (handleTapSize / 2), width: handleTapSize, height: handleTapSize)
        self.leftBottomHandle.frame = CGRect(x: cropRect.origin.x - (handleTapSize / 2), y: cropRect.origin.y - (handleTapSize / 2) + cropRect.size.height, width: handleTapSize, height: handleTapSize)
        self.rightBottomHandle.frame = CGRect(x: cropRect.origin.x - (handleTapSize / 2) + cropRect.size.width, y: cropRect.origin.y - (handleTapSize / 2) + cropRect.size.height, width: handleTapSize, height: handleTapSize)

        self.backMoveHandle.frame = cropRect
    }
    
    
    func updateCropArea(_ rect: CGRect) {
        let frameRatio = self.bounds.size.width / self.bounds.size.height
        var videoRatio = 9.0/16.0
        
        if let config = ShopLiveShortformEditorConfigurationManager.shared.shortformUploadConfiguration {
            videoRatio = CGFloat( config.videoCropOption.width ) / CGFloat( config.videoCropOption.height )
        }
        
        if frameRatio == videoRatio {
            cropRect = self.bounds
        } else {
            if videoRatio >= 1 { //세로가 가로보다 작은 경우
                let height = self.bounds.width / videoRatio
                cropRect.origin = CGPoint(x: 0 , y: floor(self.bounds.height / 2) - floor( height / 2 ))
                cropRect.size = CGSize(width: self.bounds.width, height: height)
            }
            else {
                let width = self.bounds.height * videoRatio
                cropRect.origin = CGPoint(x: floor(self.bounds.width / 2) - floor(width / 2) , y: 0)
                cropRect.size = CGSize(width: width, height: self.bounds.height)
            }
        }
        updateHandleViews()
        drawCropView()
    }
    
    
    
    private func drawCropView() {
        let rBounds = self.bounds
        let context = UIGraphicsGetCurrentContext()
       
        
        let lineSize: CGFloat = 2
        let linePostion: CGFloat = lineSize / 2
        let cornerSize: CGFloat = 5
        let cornerPostion: CGFloat = cornerSize / 2
        
        let clearBounds = CGRect(x: cropRect.origin.x + cornerSize, y: cropRect.origin.y + cornerSize, width: cropRect.width - (cornerSize * 2), height: cropRect.height - (cornerSize * 2))
        
        
        context?.setFillColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        context?.fill([rBounds])
        
        // top line
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(lineSize)
        context?.move(to: CGPoint(x: cropRect.origin.x, y: cropRect.origin.y + linePostion))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cropRect.size.width, y: cropRect.origin.y + linePostion))
        context?.strokePath()
        
        // left line
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(lineSize)
        context?.move(to: CGPoint(x: cropRect.origin.x + linePostion, y: cropRect.origin.y))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + linePostion, y: cropRect.origin.y + cropRect.size.height))
        context?.strokePath()
        
        // right line
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(lineSize)
        context?.move(to: CGPoint(x: cropRect.origin.x + cropRect.size.width - linePostion, y: cropRect.origin.y))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cropRect.size.width - linePostion, y: cropRect.origin.y + cropRect.size.height))
        context?.strokePath()
        
        // bottom line
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(lineSize)
        context?.move(to: CGPoint(x: cropRect.origin.x, y: cropRect.origin.y + cropRect.size.height - linePostion))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cropRect.size.width, y: cropRect.origin.y + cropRect.size.height - linePostion))
        context?.strokePath()
        
        // left top corner
        // top
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(cornerSize)
        context?.move(to: CGPoint(x: cropRect.origin.x, y: cropRect.origin.y + cornerPostion))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + handleSize, y: cropRect.origin.y + cornerPostion))
        context?.strokePath()
        
        // left
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(cornerSize)
        context?.move(to: CGPoint(x: cropRect.origin.x + cornerPostion, y: cropRect.origin.y))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cornerPostion, y: cropRect.origin.y + handleSize))
        context?.strokePath()
        
        // right top
        // top
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(cornerSize)
        context?.move(to: CGPoint(x: cropRect.origin.x + cropRect.width - handleSize, y: cropRect.origin.y + cornerPostion))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cropRect.width, y: cropRect.origin.y + cornerPostion))
        context?.strokePath()
        
        // right
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(cornerSize)
        context?.move(to: CGPoint(x: cropRect.origin.x + cropRect.size.width - cornerPostion, y: cropRect.origin.y))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cropRect.size.width - cornerPostion, y: cropRect.origin.y + handleSize))
        context?.strokePath()
        
        // left bottom
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(cornerSize)
        context?.move(to: CGPoint(x: cropRect.origin.x, y: cropRect.origin.y + cropRect.size.height - cornerPostion))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + handleSize, y: cropRect.origin.y + cropRect.size.height - cornerPostion))
        context?.strokePath()
        
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(cornerSize)
        context?.move(to: CGPoint(x: cropRect.origin.x + cornerPostion, y: cropRect.origin.y + cropRect.size.height - handleSize))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cornerPostion, y: cropRect.origin.y + cropRect.size.height))
        context?.strokePath()
        
        // right bottom
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(cornerSize)
        context?.move(to: CGPoint(x: cropRect.origin.x + cropRect.size.width - handleSize, y: cropRect.origin.y + cropRect.size.height - cornerPostion))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cropRect.size.width, y: cropRect.origin.y + cropRect.size.height - cornerPostion))
        context?.strokePath()
        
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(cornerSize)
        context?.move(to: CGPoint(x: cropRect.origin.x + cropRect.size.width - cornerPostion, y: cropRect.origin.y + cropRect.size.height - handleSize))
        context?.addLine(to: CGPoint(x: cropRect.origin.x + cropRect.size.width - cornerPostion, y: cropRect.origin.y + cropRect.size.height))
        context?.strokePath()
        
        context?.setBlendMode(.clear)
        
        let clearLeft = CGRect(x: cropRect.origin.x + lineSize,
                               y: cropRect.origin.y + handleSize,
                               width: handleSize - lineSize,
                               height: cropRect.height - (handleSize * 2))
        let clearRight = CGRect(x: cropRect.origin.x + cropRect.width - lineSize - (handleSize - lineSize),
                                y: cropRect.origin.y + handleSize,
                                width: handleSize - lineSize,
                                height: cropRect.height - (handleSize * 2))
        let clearTop = CGRect(x: cropRect.origin.x + handleSize,
                              y: cropRect.origin.y + lineSize,
                              width: cropRect.width - (handleSize * 2),
                              height: (handleSize - lineSize))
        let clearBottom = CGRect(x: cropRect.origin.x + handleSize,
                                 y: cropRect.origin.y + cropRect.height - (handleSize - lineSize) - lineSize,
                                 width: cropRect.width - (handleSize * 2),
                                 height: (handleSize - lineSize))
        context?.fill([clearBounds, clearLeft, clearRight, clearTop, clearBottom])
        
        gridView.frame = cropRect
        self.setNeedsDisplay()
    }
    
    func getCropRect() -> CGRect {
        let peiceOfRateWidth = self.videoResolution.width / self.bounds.width
        let peiceOfRateHeight = self.videoResolution.height / self.bounds.height
        let newVideoSize: CGSize = CGSize(width: cropRect.width * peiceOfRateWidth, height: cropRect.height * peiceOfRateHeight)

        return CGRect(x: cropRect.minX * peiceOfRateWidth, y: cropRect.minY * peiceOfRateHeight, width: newVideoSize.width, height: newVideoSize.height)
    }
    
    func setCropResolution(_ resolution: CGSize) {
        self.cropResolution = resolution
    }
    
}

