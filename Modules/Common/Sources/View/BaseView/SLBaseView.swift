//
//  BaseView.swift
//  ShopliveCommon
//
//  Created by James Kim on 11/18/22.
//

import UIKit

open class SLBaseView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        attributes()
        bindView()
        bindData()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
        attributes()
        bindView()
        bindData()
    }
    
    open func layout() { }
    open func attributes() { }
    open func bindView() { }
    open func bindData() { }
    
    open var touchEventHandler: ((Set<UITouch>, UIEvent?) -> ())? = nil
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEventHandler?(touches, event)
    }
}
