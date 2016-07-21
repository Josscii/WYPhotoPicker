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

class NewPickerLayout: UICollectionViewFlowLayout {
    
    // initializers
    
    override init() {
        super.init()
        
        scrollDirection = .Horizontal
        minimumInteritemSpacing = 5
        sectionInset.left = 5
        sectionInset.right = 5
        
        registerClass(PickerBadgeCell.self, forDecorationViewOfKind: "badge")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // constants
    
    var offsetX: CGFloat {
        return collectionView!.contentOffset.x
    }
    
    var numberOfItems: Int {
        return collectionView!.numberOfItemsInSection(0)
    }
    
    let badgeSize = CGSize(width: 31, height: 31)
    
    // layout methods
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    override func prepareLayout() {
        super.prepareLayout()
        
        cache.removeAll()
        
        guard let collectionView = collectionView as? PickerCollectionView else { return }
        
        if !collectionView.selectionMode { return }
        
        for item in 0 ..< numberOfItems {
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            let attr = layoutAttributesForDecorationViewOfKind("badge", atIndexPath: indexPath)!
            cache.append(attr)
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElementsInRect(rect)!
        
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let cellAttribute = layoutAttributesForItemAtIndexPath(indexPath)!
        
        // add decoration
        let decorationAttribute = PickerLayoutAttributes(forDecorationViewOfKind: elementKind, withIndexPath: indexPath)
        
        let screenRightEdgeX = offsetX + screenWidth
        
        let decorationOrignX = max(cellAttribute.frame.minX, min(screenRightEdgeX - badgeSize.width, cellAttribute.frame.maxX - badgeSize.width))
        
        let frame = CGRect(x: decorationOrignX, y: cellAttribute.frame.maxY - badgeSize.height, width: badgeSize.width, height: badgeSize.height)
        
        if let cell = collectionView!.cellForItemAtIndexPath(indexPath) as? PickerCell {
            decorationAttribute.selected = cell.selected
        }
        
        decorationAttribute.frame = frame
        decorationAttribute.zIndex = 1
        
        return decorationAttribute
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return PickerLayoutAttributes.self
    }
}