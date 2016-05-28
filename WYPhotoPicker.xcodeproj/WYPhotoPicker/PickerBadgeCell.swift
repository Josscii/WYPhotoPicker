//
//  PickerBadgeCell.swift
//  WYPhotoPicker
//
//  Created by Josscii on 16/5/26.
//  Copyright © 2016年 Josscii. All rights reserved.
//

import UIKit

class PickerBadgeCell: UICollectionReusableView {
    
    var selectMarkImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        selectMarkImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        selectMarkImageView.image = UIImage(named: "icon_uncheck")
        
        addSubview(selectMarkImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let attr = layoutAttributes as! PickerLayoutAttributes
        
        selectMarkImageView.image = attr.selected ? UIImage(named: "icon_checked") : UIImage(named: "icon_uncheck")
    }
}
