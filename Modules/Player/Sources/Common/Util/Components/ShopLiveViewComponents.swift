//
//  ShopLiveViewComponentes.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 2023/07/03.
//

import Foundation
import UIKit
import AVKit
import WebKit
import ShopliveSDKCommon



internal let shopLiveViewTag: Int = -999999

public class  SLWindow: UIWindow { }

// Custom subpublic public class of UIViewController
public class SLViewController: UIViewController {
    let identity: String = "ShopLiveViewComponents"
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.tag = shopLiveViewTag
        self.view.subviews.forEach { view in
            view.tag = shopLiveViewTag
        }
    }
    
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.view.tag = shopLiveViewTag
        viewControllerToPresent.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.present(viewControllerToPresent, animated: flag,completion: completion)
    }
    
    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc , sender: sender)
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc, sender: sender)
    }
}

// Custom subpublic class  of UIAlertController (with actions)
public class  SLAlertController: UIAlertController {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLAlertController
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.tag = shopLiveViewTag
        self.view.subviews.forEach { view in
            view.tag = shopLiveViewTag
        }
    }
    
    public convenience init(myTitle: String?, myMessage: String?, preferredStyle: UIAlertController.Style){
        self.init(title: myTitle, message: myMessage, preferredStyle: preferredStyle)
        self.view.tag = shopLiveViewTag
        self.view.subviews.forEach { view in
            view.tag = shopLiveViewTag
        }
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.view.tag = shopLiveViewTag
        viewControllerToPresent.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.present(viewControllerToPresent, animated: flag,completion: completion)
    }
    
    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc, sender: sender)
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.showDetailViewController(vc , sender: sender)
    }
}

// Custom subpublic class  of UIActivityViewController
public class  SLActivityViewController: UIActivityViewController {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLActivityViewController
    override public init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
        self.view.tag = shopLiveViewTag
        self.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
    }
    
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.view.tag = shopLiveViewTag
        viewControllerToPresent.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.present(viewControllerToPresent, animated: flag,completion: completion)
    }
    
    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc, sender: sender)
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.showDetailViewController(vc , sender: sender)
    }
}

// Custom subpublic public class of UINavigationController
public class SLNavigationController: UINavigationController {
    let identity: String = "ShopLiveViewComponents"
    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.view.tag = shopLiveViewTag
        viewController.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.view.tag = shopLiveViewTag
        viewControllerToPresent.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.present(viewControllerToPresent, animated: flag,completion: completion)
    }
    
    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc, sender: sender)
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.showDetailViewController(vc, sender: sender)
    }
    
    // Custom implementation for SLNavigationController
}

// Custom subpublic public class of UITabBarController
public class SLTabBarController: UITabBarController {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLTabBarController
    
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.view.tag = shopLiveViewTag
        viewControllerToPresent.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.present(viewControllerToPresent, animated: flag,completion: completion)
    }
    
    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc, sender: sender)
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.showDetailViewController(vc , sender: sender)
    }
}

// Custom subpublic public class of UISplitViewController
public class SLSplitViewController: UISplitViewController {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLSplitViewController
    
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.view.tag = shopLiveViewTag
        viewControllerToPresent.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.present(viewControllerToPresent, animated: flag,completion: completion)
    }
    
    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc, sender: sender)
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.showDetailViewController(vc , sender: sender)
    }
    
}

// Custom subpublic public class of UIPageViewController
public class  SLPageViewController: UIPageViewController {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLPageViewController
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.view.tag = shopLiveViewTag
        viewControllerToPresent.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.present(viewControllerToPresent, animated: flag,completion: completion)
    }
    
    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc, sender: sender)
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.showDetailViewController(vc , sender: sender)
    }
}

// Custom subpublic class  of UIView
public class  SLView: UIView {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLView
}

// Custom subpublic class  of UIImageView
public class  SLImageView: UIImageView {
    let identity: String = "ShopLiveViewComponents"
    
    // Custom implementation for SLImageView
}

// Custom subpublic class  of UIActivityIndicatorView
public class  SLActivityIndicatorView: UIActivityIndicatorView {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLActivityIndicatorView
}

// Custom subpublic class  of UITextField
public class  SLTextField: UITextField {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLTextField
}

// Custom subpublic class  of UITableView
public class  SLTableView: UITableView {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLTableView
}

// Custom subpublic class  of UICollectionView
public class  SLCollectionView: UICollectionView {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLCollectionView
}

// Custom subpublic class  of UIStackView
public class  SLStackView: UIStackView {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLStackView
}

// Custom subpublic class  of UISegmentedControl
public class  SLSegmentedControl: UISegmentedControl {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLSegmentedControl
}

// Custom subpublic class  of UISlider
public class  SLSlider: UISlider {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLSlider
}

// Custom subpublic class  of UIProgressView
public class  SLProgressView: UIProgressView {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLProgressView
}

// Custom subpublic class  of UISwitch
public class  SLSwitch: UISwitch {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLSwitch
}

// Custom subpublic class  of UIDatePicker
public class  SLDatePicker: UIDatePicker {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLDatePicker
}

// Custom subpublic class  of UIPickerView
public class  SLPickerView: UIPickerView {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLPickerView
}

// Custom subpublic class  of UIPageControl
public class  SLPageControl: UIPageControl {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLPageControl
}

// Custom subpublic class  of UISearchBar
public class  SLSearchBar: UISearchBar {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLSearchBar
}

// AVKit Subclasses
public class SLAVPlayerViewController: AVPlayerViewController {
    let identity: String = "ShopLiveViewComponents"
    // Custom implementation for SLAVPlayerViewController
    override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.view.tag = shopLiveViewTag
        viewControllerToPresent.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.present(viewControllerToPresent, animated: flag,completion: completion)
    }
    
    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.show(vc, sender: sender)
    }
    
    override public func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        vc.view.tag = shopLiveViewTag
        vc.view.subviews.forEach { view  in
            view.tag = shopLiveViewTag
        }
        super.showDetailViewController(vc , sender: sender)
    }
}

// WebKit Subclasses
public class SLWKWebView: WKWebView {
    let identity: String = "ShopLiveViewComponents"
    
    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.tag = shopLiveViewTag
    }
    
    public override var inputAccessoryView: SLView? {
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
}


public class SLScrollView: UIScrollView {
    let identity: String = "ShopLiveViewComponents"
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.tag = shopLiveViewTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class SLTextView: UITextView {
    let identity: String = "ShopLiveViewComponents"
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.tag = shopLiveViewTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class SLPictureInPictureController: AVPictureInPictureController {
    let identity: String = "ShopLiveViewComponents"
}
