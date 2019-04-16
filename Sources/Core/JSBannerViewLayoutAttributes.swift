//
//  JSBannerViewLayoutAttributes.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit

open class JSBannerViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // MARK:
    open var position: CGFloat = 0.0
    
    // MARK:
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? JSBannerViewLayoutAttributes else {
            return false
        }
        var isEqual = super.isEqual(object)
        isEqual = isEqual && (self.position == object.position)
        return isEqual
    }
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! JSBannerViewLayoutAttributes
        copy.position = self.position
        return copy
    }
}
