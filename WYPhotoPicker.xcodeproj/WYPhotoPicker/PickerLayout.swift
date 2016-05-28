//
//  PickerLayout.swift
//  WYPhotoPicker
//
//  Created by Josscii on 16/5/26.
//  Copyright © 2016年 Josscii. All rights reserved.
//

import UIKit

class PickerLayoutAttributes: UICollectionViewLayoutAttributes {
    var selected: Bool = false
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! PickerLayoutAttributes
        copy.selected = selected
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributtes = object as? PickerLayoutAttributes {
            if( attributtes.selected == selected) {
                return super.isEqual(object)
            }
        }
        return false
    }
}


class PickerLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        registerClass(PickerBadgeCell.self, forDecorationViewOfKind: "badge")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var offsetX: CGFloat {
        return collectionView!.contentOffset.x
    }
    
    let badgeSize = CGSize(width: 31, height: 31)
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElementsInRect(rect) as! [PickerLayoutAttributes]
        
        var badgeAttributes = [PickerLayoutAttributes]()
        
        for attributes in layoutAttributes {
            
            if let collectionView = collectionView as? PickerCollectionView,
                cell = collectionView.cellForItemAtIndexPath(attributes.indexPath)  {
                
                if collectionView.selectionMode {
                    
                    let attr = PickerLayoutAttributes(forDecorationViewOfKind: "badge", withIndexPath: attributes.indexPath)
                    
                    attr.selected = cell.selected
                    
                    let offset = attributes.frame.origin.x - offsetX
                    
                    var frame = CGRect(x: attributes.frame.maxX - badgeSize.width, y: itemSize.height - badgeSize.height, width: badgeSize.width, height: badgeSize.height)
                    
                    if offset > 0.5 * screenWidth && offset < screenWidth {
                        frame.origin.x = max(attributes.frame.minX, attributes.frame.minX + (screenWidth - offset) - badgeSize.width)
                    }
                    
                    attr.frame = frame
                    
                    badgeAttributes.append(attr)
                }
            }
        }
        
        layoutAttributes.appendContentsOf(badgeAttributes)
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return PickerLayoutAttributes.self
    }
}
