//
//  SLAlbumSelectTableViewCell.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit




class SLAlbumSelectTableViewCell : UITableViewCell {

    
    static let cellId = "slAlbumselecteTableViewCellId"
    
    private var thumbnailView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .red
        return imageView
    }()
    
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.set(size: 16, weight: ._600)
        label.textColor = .white
        label.text = "album title"
        return label
    }()
    
    private var contentsCountLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.set(size: 13, weight: ._500)
        label.textColor = .init(red: 143, green: 143, blue: 143, aa: 1)
        label.text = "11,111"
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
        self.selectionStyle = .none
        self.accessoryType = .none
        self.backgroundColor = .init(red: 31, green: 31, blue: 31,aa: 1)
    }

    required init?(coder : NSCoder) {
        fatalError()
    }
    
    func setImage(image : UIImage?){
        if let image = image {
            self.thumbnailView.image = image
            self.thumbnailView.isHidden = false
        }
        else {
            self.thumbnailView.image = nil
            self.thumbnailView.isHidden = true
        }
    }
    
    func configure(title : String, count : Int) {
        self.titleLabel.text = title
        //TODO: - 나중에 , 찍는 formatter 가져와서 써야함
        self.contentsCountLabel.text = "\(count)"
    }
    
}
extension SLAlbumSelectTableViewCell {
    private func setLayout() {
        let titleContentStack = UIStackView(arrangedSubviews: [titleLabel, contentsCountLabel])
        titleContentStack.translatesAutoresizingMaskIntoConstraints = false
        titleContentStack.axis = .vertical
        titleContentStack.distribution = .fillEqually
        
        
        let wholeStack = UIStackView(arrangedSubviews: [thumbnailView, titleContentStack])
        wholeStack.translatesAutoresizingMaskIntoConstraints = false
        wholeStack.axis = .horizontal
        wholeStack.spacing = 16
        wholeStack.isLayoutMarginsRelativeArrangement = true
        wholeStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        
        
        self.addSubview(wholeStack)
        
        NSLayoutConstraint.activate([
            
            thumbnailView.widthAnchor.constraint(equalToConstant: 56),
            
            wholeStack.topAnchor.constraint(equalTo: self.topAnchor),
            wholeStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            wholeStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            wholeStack.heightAnchor.constraint(equalToConstant: 56),
        ])
        
    }
}
