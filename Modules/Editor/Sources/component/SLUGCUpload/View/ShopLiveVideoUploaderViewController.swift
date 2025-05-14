//
//  SLUGCUploadViewController.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/19/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon
import WebKit

protocol ShopLiveShortformUploaderViewControllerDelegate: NSObjectProtocol {
    func onOpenVideoEditor()
    func onPlayPreview(root: UIViewController, url: String)
    func onOpenCoverPicker(editor: UIViewController?, shortsId: String, videoUrl: String?)
    func onEvent(name: String, Payload: [String : Any]?)
    func onError(error: ShopLiveCommonError)
    func onUploadComplete()
}

class ShopLiveShortformUploaderViewController: UIViewController {
    private let webView: SLWebView = SLWebView()
    let reactor: ShopLiveShortformUploaderReactor
    
    weak var delegate: ShopLiveShortformUploaderViewControllerDelegate?
    
    init(uploaderData: ShopLiveShortformUploaderData) {
        reactor = ShopLiveShortformUploaderReactor(uploadData: uploaderData)
        super.init(nibName: nil, bundle: nil)
        ShopLiveDelegateInternalManager.shared.insertMessageDelegate(delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action( .viewWillAppear )
    }
    
    override func viewDidLoad() {
        setLayout()
        bindReactor()
        super.viewDidLoad()
        SLLoadingIndicatorView.show()
        reactor.action( .viewDidLoad )
        webView.slWebResponseDelegate = self
        webView.webViewNavigationDelegate = self
    }

    deinit {
        ShopLiveDelegateInternalManager.shared.removeDelegate()
        ShopLiveLogger.memoryLog("[SLUGCUploadViewController] deinited")
    }
    
    private func bindReactor() {
        reactor.mainQueueResultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .loadWebView(let url):
                    self.onLoadWebView(url: url)
                case .sendWebEvent(let event, let parameter):
                    self.onSendWebEvent(event: event, parameter: parameter)
                case .sendShortEvent(let event, let parameter):
                    self.onSendShortEvent(event: event, parameter: parameter)
                case .openPreview(let data):
                    self.onOpenPreview(data: data)
                case .openVideoEditor:
                    self.onOpenVideoEditor()
                case .openCoverPicker(let shortsId, let videoUrl):
                    self.onOpenCoverPicker(shortsId: shortsId, videoUrl: videoUrl)
                case .closeViewController:
                    self.onCloseViewController()
                case .onError(let error):
                    self.onError(error: error)
                case .onEvent(let name,let payload):
                    self.onEvent(name: name, payload: payload)
                case .uploadComplete:
                    self.onUploadComplete()
                }
            }
        }
    }
    
    private func onLoadWebView(url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    private func onSendWebEvent(event: ShopLiveShortformUploaderWebInterface, parameter: [String : Any]?) {
        webView.sendEventToWeb(event: event.functionString, parameter: parameter, wrapping: false)
    }
    
    private func onSendShortEvent(event: String, parameter: [String: Any]?) {
        ShopLiveLogger.tempLog("[SLUGCUploadViewController] \(#function) is called | event : \(event), parameter: \(parameter)")
        webView.sendShortsEvent(event: event, parameter: parameter, completion: { })
    }
    
    private func onOpenPreview(data: SLUploadAttachmentInfo) {
        delegate?.onPlayPreview(root: self, url: data.videoUrl)
    }
    
    private func onOpenVideoEditor() {
        delegate?.onOpenVideoEditor()
    }
    
    private func onOpenCoverPicker(shortsId: String, videoUrl: String?) {
        delegate?.onOpenCoverPicker(editor: self, shortsId: shortsId, videoUrl: videoUrl)
    }
    
    private func onCloseViewController() {
        dismiss(animated: true)
    }
    
    private func onError(error: ShopLiveCommonError) {
        delegate?.onError(error: error)
    }
    
    private func onEvent(name: String, payload: [String : Any]?) {
        delegate?.onEvent(name: name, Payload: payload)
    }
    
    private func onUploadComplete() {
        delegate?.onUploadComplete()
    }
    
    private func sendShortId(id: String) {
        let sendData: [String : Any] = [ "shorts" : [ "id": id ]]
        onSendShortEvent(event: "SET_SHOW_UGC_EDIT_PAGE_WITH_SHORTS", parameter: sendData)
    }
}

extension ShopLiveShortformUploaderViewController: ShopLiveShortformUploaderMessageDelegate {
    func upload(id: String) {
        ShopLiveLogger.tempLog("[ShopLiveShortformUploaderMessageDelegate] Upload : \(id)")
        sendShortId(id: id)
    }
    
    func successCoverChange() {
        onSendShortEvent(event: "ON_SUCCESS_SDK_UGC_COVER_CHANGE", parameter: nil)
    }
}

extension ShopLiveShortformUploaderViewController {
    private func setLayout() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func backBtn(sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ShopLiveShortformUploaderViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        SLLoadingIndicatorView.hide()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        SLLoadingIndicatorView.hide()
        
        ShopLiveLogger.tempLog("[ShopLiveShortformUploaderViewController] webView Did Finish")
        
        // 고객사가 init 하는 데이터 중 shortsId가 있을 경우 편집 화면 진입
        if let shortsId = reactor.uploaderData?.shortsId {
            sendShortId(id: shortsId)
        }
    }
}
