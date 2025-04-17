//
//  V2ShortsCollectionExampleView.swift
//  ShortformDemo
//
//  Created by sangmin han on 12/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveShortformSDK
import ShopliveSDKCommon

class V2ShortsCollectionExampleView : UIViewController {
    
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
    
    private var removeLastIndexBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitle("removeLatIndex", for: .normal)
        return btn
    }()

    
    var shortsCollectionView : ShopLiveShortsCollectionView?
   
    var reference : String? = nil
    var hasMore : Bool? = nil
    var firstIndexShortsIdOrSrn : String = ""
    var ids : [ShopLiveShortformIdData] = []
    var upperPaginationCount : Int = 0
    var currentLandingId : String?
    var blockViewDidlayoutSubView : Bool = false
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.reference = nil
        self.hasMore = nil
        ShopLiveLogger.showLog = true
        self.callShortsCollectionAPI(count: ShortFormConfigurationInfosManager.shared.getDetailApiInitializeCount() ) { [weak self] idsMoreData, error in
            guard let self = self else { return }
            guard let ids = idsMoreData?.ids else { return }
            self.ids = ids
            self.firstIndexShortsIdOrSrn = ids.first?.shortsId ?? ""
            var currentId : String = ""
            if let fifthCurrentId = ids[safe : 6]?.shortsId {
                currentId = fifthCurrentId
            }
            self.currentLandingId = currentId
            ShopLiveLogger.tempLog("[HASSAN LOG] \(ids.map({ $0.shortsId }))")
            self.shortsCollectionView = ShopLiveShortsCollectionView(shortformIdsData: ShopLiveShortformIdsData(ids: ids, currentId: currentId ),
                                                                     dataSourceDelegate: self,
                                                                     shortsCollectionDelegate: self)
            self.shortsCollectionView?.translatesAutoresizingMaskIntoConstraints = false
            self.setLayout()
            self.shortsCollectionView?.action( .setMuted(OptionSettingModel.isDetailViewMuted) )
            
        }
        backBtn.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        btn.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        removeFirstIndexBtn.addTarget(self, action: #selector(removeFirstIndexBtnTapped), for: .touchUpInside)
        removeLastIndexBtn.addTarget(self, action: #selector(removeLastIndexBtnTapped), for: .touchUpInside)
    }
    
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        guard let shortsCollectionView = shortsCollectionView else { return }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ShopLiveLogger.tempLog("[VIDEO_TOTAL_VIEWING_TIME] viewDidAppear")
        guard let shortsCollectionView = shortsCollectionView else { return }
        shortsCollectionView.action( .play )
        shortsCollectionView.action( .setActive )
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ShopLiveLogger.tempLog("[VIDEO_TOTAL_VIEWING_TIME] viewDidDisappear")
        guard let shortsCollectionView = shortsCollectionView else { return }
        shortsCollectionView.action( .pause )
        shortsCollectionView.action( .setInActive )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        let vc = V2ShortsCollectionExampleView()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func removeFirstIndexBtnTapped() {
        guard let shortsCollectionView = shortsCollectionView else { return }
        guard let firstShortsId = ids.first?.shortsId else { return }
        ids = Array(ids.dropFirst())
        ShopLiveLogger.tempLog("[ONREMOVE] firstIndexShortsIdOrSrn \(firstShortsId)")
        shortsCollectionView.action( .remove(firstShortsId) )
    }
    
    @objc
    private func removeLastIndexBtnTapped() {
        guard let shortsCollectionView = shortsCollectionView else { return }
        guard let lastShortsId = ids.last?.shortsId else { return }
        ids = Array(ids.dropLast())
        ShopLiveLogger.tempLog("[ONREMOVE] firstIndexShortsIdOrSrn \(lastShortsId)")
        shortsCollectionView.action( .remove(lastShortsId) )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        guard let shortsCollectionView = shortsCollectionView else { return }
        
        shortsCollectionView.action( .onStartRotation(size: shortsCollectionView.frame.size) )
        coordinator.animate { context in
            shortsCollectionView.action( .onChangingRotation(size: shortsCollectionView.frame.size) )
        } completion: { context in
            shortsCollectionView.action( .onFinishedRotation(size: shortsCollectionView.frame.size) )
        }
    }
    
}
extension V2ShortsCollectionExampleView {
    private func setLayout() {
        guard let shortsCollectionView = shortsCollectionView else { return }
        self.view.addSubview(shortsCollectionView)
        self.view.addSubview(btn)
        self.view.addSubview(backBtn)
        self.view.addSubview(removeFirstIndexBtn)
        self.view.addSubview(removeLastIndexBtn)
        
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
            
            removeLastIndexBtn.topAnchor.constraint(equalTo: removeFirstIndexBtn.bottomAnchor, constant: 5),
            removeLastIndexBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            removeLastIndexBtn.widthAnchor.constraint(equalToConstant: 150),
            removeLastIndexBtn.heightAnchor.constraint(equalToConstant: 50),
            
            shortsCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 60),
            shortsCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shortsCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shortsCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        
        shortsCollectionView.resultHandler = { [weak self] result in
            switch result {
            case .didScrollToShortsId(let shortsId):
                ShopLiveLogger.tempLog("didScrollToShortsId \(shortsId)")
                break
            }
        }
    }
}
extension V2ShortsCollectionExampleView : ShortsCollectionViewDataSourcRequestDelegate {
    func onShortformListUpwardPagingation(completion: @escaping (((ShopLiveShortformSDK.ShopLiveShortformIdsMoreData?, (any Error)?)) -> ())) {
        callShortsCollectionAPI(reversed: true,count : ShortFormConfigurationInfosManager.shared.getDetailApiPaginationCount()) { data,error in
            if let data = data {
                let shortsIds = data.ids?.map({ $0.shortsId })
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
    
    func onShortformListPaginationError(error: Error) {
        
    }
    
    func onShortformListDownwardPagination(completion: @escaping (((ShopLiveShortformSDK.ShopLiveShortformIdsMoreData?, Error?)) -> ())) {
        callShortsCollectionAPI(count : ShortFormConfigurationInfosManager.shared.getDetailApiPaginationCount()) { data,error in
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
    
    func callShortsCollectionAPI(reversed : Bool = false,count : Int,  completion : @escaping((ShopLiveShortformIdsMoreData?,Error?) -> ())) {
        Test2ShortsCollectionAPI(reference: self.reference,
                                 count: count).request { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let shortsList = response.shortsList else {
                    completion(nil,nil)
                    return
                }
                self.reference = response.reference
                self.hasMore = response.hasMore
                var idsData = response.shortsList?.compactMap({ shortsModel in
                    return ShopLiveShortformIdData(shortsId: shortsModel.shortsId ?? "", payload: ["createIsFollow" : true, "description" : "\(shortsModel.shortsId)"] )
                })
                
                if reversed {
                    idsData = response.shortsList?.reversed().compactMap({ shortsModel in
                        self.upperPaginationCount += 1
                        return ShopLiveShortformIdData(shortsId: shortsModel.shortsId ?? "", payload: ["title" : shortsModel.shortsDetail?.title ?? "" ,"createIsFollow" : true, "description" : "\(shortsModel.shortsId) upper count \(self.upperPaginationCount)"] )
                    })
                }
                else {
                    idsData = response.shortsList?.compactMap({ shortsModel in
                        return ShopLiveShortformIdData(shortsId: shortsModel.shortsId ?? "", payload: ["title" : shortsModel.shortsDetail?.title ?? "","createIsFollow" : true, "description" : "\(shortsModel.shortsId)"] )
                    })
                }
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
extension V2ShortsCollectionExampleView : ShopLiveShortformReceiveHandlerDelegate {
    func onShortsAttached(data: ShopLiveShortformData) {
        ShopLiveLogger.tempLog("[SHORTFORMATTACH] attach \(data.shortsId)")
    }
    
    func onShortsDetached(data: ShopLiveShortformData) {
        ShopLiveLogger.tempLog("[SHORTFORMATTACH] detach \(data.shortsId)")
    }
    
    func onEvent(messenger: ShopLiveShortformMessenger?, command: String, payload: String?) {
        switch command {
        case "DETAIL_EMPTY":
            ShopLiveLogger.tempLog("[DETAIL_EMPTY]")
        case "DETAIL_ACTIVE":
            let srn = extractShortsId(payload: payload ?? "")
            ShopLiveLogger.tempLog("[DETAIL_ACTIVE]")
            break
        case "VIDEO_TOTAL_VIEWING_TIME":
            ShopLiveLogger.tempLog("[VIDEO_TOTAL_VIEWING_TIME] payload \(payload)")
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
        
        params["count"] = count
        //ShortFormConfigurationInfosManager.shared.getDetailApiInitializeCount()

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
    var count : Int



}
