//
//  ShortsCollectionView.swift
//  ShortformDemo
//
//  Created by sangmin han on 10/31/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveShortformSDK
import ShopliveSDKCommon


class ViewController2 : UIViewController {
    
    lazy var shortsCollectionView : ShopLiveShortsCollectionView = {
        let view = ShopLiveShortsCollectionView(requestData: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

class ShortsCollectionExampleView : UIViewController {
    
    private var backBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitle("back", for: .normal)
        return btn
    }()
    
    private var btn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitle("next", for: .normal)
        return btn
    }()
    
    private var removeFirstIndexBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitle("removeFirstIndex", for: .normal)
        return btn
    }()

//    lazy var shortsCollectionView : ShopLiveShortsCollectionView = {
//        
//        
//        let view = ShopLiveShortsCollectionView(shortformIdsData: <#T##ShopLiveShortformIdsData#>,
//                                                dataSourceDelegate: <#T##any ShortsCollectionViewDataSourcRequestDelegate#>,
//                                                shortsCollectionDelegate: <#T##(any ShopLiveShortformReceiveHandlerDelegate)?#>)
////        let view = ShopLiveShortsCollectionView(requestData: nil)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    var shortsCollectionView : ShopLiveShortsCollectionView?
    
    
    
    var reference : String? = nil
    var hasMore : Bool? = nil
    var firstIndexShortsIdOrSrn : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.reference = nil
        self.hasMore = nil
        self.callShortsCollectionAPI { [weak self] idsMoreData, error in
            guard let self = self else { return }
            guard let ids = idsMoreData?.ids else { return }
            self.firstIndexShortsIdOrSrn = ids.first?.shortsId ?? ""
            self.shortsCollectionView = ShopLiveShortsCollectionView(shortformIdsData: ShopLiveShortformIdsData(ids: ids),
                                                                     dataSourceDelegate: self,
                                                                     shortsCollectionDelegate: self)
            self.shortsCollectionView?.translatesAutoresizingMaskIntoConstraints = false
            self.setLayout()
        }
        backBtn.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        btn.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        removeFirstIndexBtn.addTarget(self, action: #selector(removeFirstIndexBtnTapped), for: .touchUpInside)
    }
    
    @objc
    private func backBtnTapped() {
        if self.navigationController?.viewControllers.count == 1 {
            self.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func nextBtnTapped() {
        let vc = ShortsCollectionExampleView()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func removeFirstIndexBtnTapped() {
        guard let shortsCollectionView = shortsCollectionView else { return }
        ShopLiveLogger.tempLog("[ONREMOVE] firstIndexShortsIdOrSrn \(self.firstIndexShortsIdOrSrn)")
        shortsCollectionView.action( .remove(self.firstIndexShortsIdOrSrn) )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        guard let shortsCollectionView = shortsCollectionView else { return }
        shortsCollectionView.action( .onStartRotation(size: size) )
        
        coordinator.animate { [weak self] context in
            shortsCollectionView.action( .onChangingRotation(size: size) )
        } completion: { [weak self] context in
            shortsCollectionView.action( .onFinishedRotation(size: size) )
        }
    }
    
}
extension ShortsCollectionExampleView {
    private func setLayout() {
        guard let shortsCollectionView = shortsCollectionView else { return }
        self.view.addSubview(shortsCollectionView)
        self.view.addSubview(btn)
        self.view.addSubview(backBtn)
        self.view.addSubview(removeFirstIndexBtn)
        
        NSLayoutConstraint.activate([
            backBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            backBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 50),
            backBtn.heightAnchor.constraint(equalToConstant: 50),
            
            btn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            btn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            btn.widthAnchor.constraint(equalToConstant: 50),
            btn.heightAnchor.constraint(equalToConstant: 50),
            
            
            removeFirstIndexBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            removeFirstIndexBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            removeFirstIndexBtn.widthAnchor.constraint(equalToConstant: 150),
            removeFirstIndexBtn.heightAnchor.constraint(equalToConstant: 50),
            
            shortsCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 60),
            shortsCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shortsCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shortsCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            
            
        ])
    }
}
extension ShortsCollectionExampleView : ShortsCollectionViewDataSourcRequestDelegate {
    func onShortformListPaginationError(error: Error) {
        
    }
    
    func onShortformListPagination(completion: @escaping (((ShopLiveShortformSDK.ShopLiveShortformIdsMoreData?, Error?)) -> ())) {
        callShortsCollectionAPI { data,error in
            if let data = data {
                completion((data,nil))
            }
            else if let error = error {
                completion((nil,error))
            }
            else {
                completion((nil,nil))
            }
        }
    }
    
    func callShortsCollectionAPI(completion : @escaping((ShopLiveShortformIdsMoreData?,Error?) -> ())) {
        Test2ShortsCollectionAPI(reference: self.reference).request { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let shortsList = response.shortsList else {
                    completion(nil,nil)
                    return
                }
                self.reference = response.reference
                self.hasMore = response.hasMore
                let idsData = response.shortsList?.compactMap({ shortsModel in
                    return ShopLiveShortformIdData(shortsId: shortsModel.shortsId ?? "", payload: ["createIsFollow" : true] )
                })
                let moreData = ShopLiveShortformIdsMoreData(ids: idsData ,hasMore: hasMore)
                DispatchQueue.main.async {
                    completion(moreData,nil)
                }
                break
            case .failure(let error):
                ShopLiveLogger.tempLog("[V2SHORTFORMEXAMPLE] error \(error.localizedDescription)")
                completion(nil,error)
                break
            }
        }
    }
}
extension ShortsCollectionExampleView : ShopLiveShortformReceiveHandlerDelegate {
    func onEvent(messenger: ShopLiveShortformMessenger?, command: String, payload: String?) {
        switch command {
        case "DETAIL_SHORTFORM_MORE_ENDED":
            ShopLiveLogger.tempLog("[DETAIL_SHORTFORM_MORE_ENDED]")
            break
        case "DETAIL_ACTIVE":
            let srn = extractShortsId(payload: payload ?? "")
            ShopLiveLogger.tempLog("[DETAIL_ACTIVE]")
            break
        default:
            break
        }
    }
    
    private func extractShortsId(payload : String) -> String {
        if let jsonData = payload.data(using: .utf8) {
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    let shorts = dictionary["shorts"] as? [String : Any]
                    if let shortsId = shorts?["shortsId"] as? String,
                       let srn = shorts?["srn"] as? String {
                        return srn
                    }
                }
            } catch {
                print("JSON 변환 실패: \(error.localizedDescription)")
            }
        }
        return "no shortsId"
    }
}
struct Test2ShortsCollectionAPI: APIDefinition {
    typealias ResultType = SLShortsCollectionModel

    var baseUrl: String {
        guard let ak = ShopLiveCommon.getAccessKey() else {
            return "https://shortform-api.shoplive.cloud"
        }
        if ak == "e4cscSXMMHtEQnMiZI5E" {
            return "https://qa-shortform-api.shoplive.cloud"
        }
        else if ak == "a1AW6QRCXeoZ9MEWRdDQ" {
            return "https://dev-shortform-api.shoplive.cloud"
        }
        else {
            return "https://shortform-api.shoplive.cloud"
        }
        
    }

    var urlPath: String {
        if let ak = ShopLiveCommon.getAccessKey(), ak.isEmpty == false {
            return "/sdk/v1/\(ak)/shorts/collection"
        }
        else {
            return "/sdk/v1/shorts/collection"
        }
    }


    var method: SLHTTPMethod {
        .post
    }

    var headers: [String : String] {
        var header : [String : String] = [:]
        header[CommonKeys.x_sl_player_app_version] = UIApplication.appVersion_SL()
        header[CommonKeys.x_sl_player_sdk_version] = ShopLiveShortform.sdkVersion
        return header
    }


    var parameters: [String : Any]? {
        var params: [String: Any] = [:]
        
        params["count"] = ShortFormConfigurationInfosManager.shared.getRequestCount()

        if let accessKey = ShopLiveCommon.getAccessKey() {
            params["accessKey"] = accessKey
        }

        if let reference = reference, reference.isEmpty == false {
            params["reference"] = reference
        }
        if let shortsId = shortsId {
            params["shortsId"] = shortsId
        }
        if let shortsCollectionsId = shortsCollectionsId {
            params["shortsCollectionId"] = shortsCollectionsId
        }
        if let shortsCollectionSrn = shortsCollectionSrn {
            params["shortsCollectionSrn"] = shortsCollectionSrn
        }
        if let tags = tags {
            params["tags"] = tags
        }
        if let tagSearchOperator = tagSearchOperator {
            params["tagSearchOperator"] = tagSearchOperator
        }
        if let brands = brands {
            params["brands"] = brands
        }
        if let shuffle = shuffle {
            params["shuffle"] = shuffle
        }
        if let type = type {
            params["type"] = type
        }

        if let finite = finite {
            params["finite"] = finite
        }

        return params
    }

    var reference : String?

    var shortsId: String?

    var shortsCollectionsId : Int?
    var shortsCollectionSrn : String?
    var tags : [String]?
    var tagSearchOperator : String?
    var brands : [String]?
    var shuffle : Bool?
    var type : String?
    var finite : Bool?



}
