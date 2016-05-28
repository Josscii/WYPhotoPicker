//
//  PickerTableViewCell.swift
//  WYPhotoPicker
//
//  Created by Josscii on 16/5/27.
//  Copyright © 2016年 Josscii. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {
    var titleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(21)
        titleLabel.textColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
