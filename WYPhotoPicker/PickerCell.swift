//
//  PickerCell.swift
//  WYPhotoPicker
//
//  Created by Josscii on 16/5/26.
//  Copyright © 2016年 Josscii. All rights reserved.
//

import UIKit

protocol PickerDelegate: class {
    func invalidateLayout(cell: UICollectionViewCell)
}

class PickerCell: UICollectionViewCell {
    weak var delegate: PickerDelegate?
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var selected: Bool {
        willSet {
            // has to judje this
            if newValue != selected {
                delegate?.invalidateLayout(self)
            }
        }
    }
}
