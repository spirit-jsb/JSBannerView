//
//  JSBannerCollectionView.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit

class JSBannerCollectionView: UICollectionView {
    
    // MARK:
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    override var scrollsToTop: Bool {
        set {
            super.scrollsToTop = false
        }
        get {
            return false
        }
    }
    
    override var contentInset: UIEdgeInsets {
        set {
            super.contentInset = .zero
            if newValue.top > 0.0 {
                let contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + newValue.top)
                self.contentOffset = contentOffset
            }
        }
        get {
            return super.contentInset
        }
    }
    
    // MARK:
    fileprivate func initialize() {
        self.contentInset = .zero
        self.decelerationRate = .fast
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        if #available(iOS 10.0, *) {
            self.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        self.scrollsToTop = false
        self.isPagingEnabled = false
    }
}
