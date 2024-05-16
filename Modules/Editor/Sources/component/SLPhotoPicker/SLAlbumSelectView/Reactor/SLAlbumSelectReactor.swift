//
//  SLAlbumSelectReactor.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import ShopliveSDKCommon
import UIKit



class SLAlbumSelectReactor : NSObject, SLReactor {
    
    enum Action {
        case registerTablView(UITableView)
        case setShow(Bool)
        case setShowWithOnlyValueChange(Bool)
        case setPhotoLibrary(SLPhotoLibrary)
        case setAssetsCollections([SLAssetsCollection])
    }
    
    enum Result {
        case show(Bool)
        case setFocusedCollection(SLAssetsCollection)
    }
    
    
    
    var resultHandler: ((Result) -> ())?
    
    private var photoLibrary : SLPhotoLibrary?
    private var tb : UITableView?
    private let cellSpacing : CGFloat = 12
    private let cellHeight : CGFloat = 56
    private var show : Bool = false
    
    private var collections : [SLAssetsCollection] = []
    
    
    func action(_ action: Action) {
        switch action {
        case .registerTablView(let tableView):
            self.onRegisterTablView(tableView: tableView)
        case .setShow(let show):
            self.onSetShow(show: show)
        case .setShowWithOnlyValueChange(let show):
            self.onSetShowWithOnlyValueChange(show: show)
        case .setPhotoLibrary(let pl):
            self.onSetPhotoLibrary(pl: pl)
        case .setAssetsCollections(let collections):
            self.onSetAssetsCollections(collections: collections)
        }
    }
    
    private func onRegisterTablView(tableView : UITableView) {
        self.tb = tableView
        self.tb?.delegate = self
        self.tb?.dataSource = self
        self.tb?.register(SLAlbumSelectTableViewCell.self, forCellReuseIdentifier: SLAlbumSelectTableViewCell.cellId)
    }
    
    private func onSetShow(show : Bool) {
        guard self.show != show else { return }
        self.show = show
        resultHandler?( .show(self.show) )
    }
    
    private func onSetShowWithOnlyValueChange(show : Bool) {
        self.show = show
    }
    
    private func onSetPhotoLibrary(pl : SLPhotoLibrary) {
        self.photoLibrary = pl
    }
    
    private func onSetAssetsCollections(collections : [SLAssetsCollection]) {
        self.collections = collections
    }
    
}
extension SLAlbumSelectReactor : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SLAlbumSelectTableViewCell.cellId, for: indexPath) as! SLAlbumSelectTableViewCell
        let collection = self.collections[indexPath.row]
        
        if let phAsset = collection.getAsset(at: collection.useCameraButton ? 1 : 0) {
            let scale = UIScreen.main.scale
            let size = CGSize(width: 80*scale, height: 80*scale)
            self.photoLibrary?.imageAsset(asset: phAsset, size: size, completionBlock: {  (image,complete) in
                DispatchQueue.main.async {
                    if let cell = tableView.cellForRow(at: indexPath) as? SLAlbumSelectTableViewCell {
                        cell.setImage(image: image)
                    }
                }
            })
        }
        else {
            cell.setImage(image: nil)
        }
        
        let title = collection.title
        let count = collection.fetchResult?.count ?? 0

        cell.configure(title: title, count: count)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight + cellSpacing
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let collection = self.collections[safe : indexPath.row] else { return }
        resultHandler?( .setFocusedCollection(collection) )
    }
}

//MARK: - GETTER
extension SLAlbumSelectReactor {
    func getCellHeight() -> CGFloat {
        return self.cellHeight + self.cellSpacing
    }
}
