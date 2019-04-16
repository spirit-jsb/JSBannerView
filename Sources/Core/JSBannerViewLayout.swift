//
//  JSBannerViewLayout.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit

class JSBannerViewLayout: UICollectionViewLayout {

    // MARK:
    var contentSize: CGSize = .zero
    var leadingSpacing: CGFloat = 0.0
    var itemSpacing: CGFloat = 0.0
    var needsReprepare: Bool = true
    var scrollDirection: JSBannerView.ScrollDirection = .horizontal
    
    fileprivate var collectionViewSize: CGSize = .zero
    fileprivate var numberOfSections: Int = 1
    fileprivate var numberOfItems: Int = 0
    fileprivate var actualInteritemSpacing: CGFloat = 0.0
    fileprivate var actualItemSize: CGSize = .zero
    
    fileprivate var bannerView: JSBannerView? {
        return self.collectionView?.superview?.superview as? JSBannerView
    }
    
    // MARK:
    override init() {
        super.init()
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK:
    open override class var layoutAttributesClass: AnyClass {
        return JSBannerViewLayoutAttributes.self
    }
    
    open override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView, let bannerView = self.bannerView else {
            return
        }
        guard self.needsReprepare || self.collectionViewSize != collectionView.frame.size else {
            return
        }
        
        self.needsReprepare = false
        self.collectionViewSize = collectionView.frame.size
        
        self.numberOfSections = bannerView.numberOfSections(in: collectionView)
        self.numberOfItems = bannerView.collectionView(collectionView, numberOfItemsInSection: 0)
        self.actualItemSize = {
            var size = bannerView.itemSize
            if size == .zero {
                size = collectionView.frame.size
            }
            return size
        }()
        
        self.actualInteritemSpacing = {
            if let transformer = bannerView.transformer {
                return transformer.proposedInterItemSpacing()
            }
            return bannerView.interitemSpacing
        }()
        self.scrollDirection = bannerView.scrollDirection
        self.leadingSpacing = self.scrollDirection == .horizontal ?
            (collectionView.frame.width - self.actualItemSize.width) * 0.5 :
            (collectionView.frame.height - self.actualItemSize.height) * 0.5
        self.itemSpacing = (self.scrollDirection == .horizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing
        
        self.contentSize = {
            let numberOfItems = self.numberOfItems * self.numberOfSections
            switch self.scrollDirection {
            case .horizontal:
                var contentSizeWidth = self.leadingSpacing * 2.0
                contentSizeWidth += CGFloat(numberOfItems - 1) * self.actualInteritemSpacing
                contentSizeWidth += CGFloat(numberOfItems) * self.actualItemSize.width
                let contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
                return contentSize
            case .vertical:
                var contentSizeHeight = self.leadingSpacing * 2.0
                contentSizeHeight += CGFloat(numberOfItems - 1) * self.actualInteritemSpacing
                contentSizeHeight += CGFloat(numberOfItems) * self.actualItemSize.height
                let contentSize = CGSize(width: collectionView.frame.width, height: contentSizeHeight)
                return contentSize
            }
        }()
        self.adjustCollectionViewBounds()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        guard self.itemSpacing > 0.0, !rect.isEmpty else {
            return layoutAttributes
        }
        let rect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))
        guard !rect.isEmpty else {
            return layoutAttributes
        }
        
        let numberOfItemsBefore = self.scrollDirection == .horizontal ?
            max(Int((rect.midX - self.leadingSpacing) / self.itemSpacing), 0) :
            max(Int((rect.midY - self.leadingSpacing) / self.itemSpacing), 0)
        let startPosition = self.leadingSpacing + CGFloat(numberOfItemsBefore) * self.itemSpacing
        let startIndex = numberOfItemsBefore
        
        var itemIndex = startIndex
        
        var origin = startPosition
        let maxPosition = self.scrollDirection == .horizontal ?
            min(rect.maxX, self.contentSize.width - self.actualItemSize.width - self.leadingSpacing) :
            min(rect.maxY, self.contentSize.height - self.actualItemSize.height - self.leadingSpacing)
        while origin - maxPosition <= max(100.0 * .ulpOfOne * abs(origin + maxPosition), .leastNonzeroMagnitude) {
            let indexPath = IndexPath(item: itemIndex % self.numberOfItems, section: itemIndex / self.numberOfItems)
            let attributes = self.layoutAttributesForItem(at: indexPath) as! JSBannerViewLayoutAttributes
            self.applyTransform(to: attributes, with: self.bannerView?.transformer)
            layoutAttributes.append(attributes)
            itemIndex += 1
            origin += self.itemSpacing
        }
        
        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = JSBannerViewLayoutAttributes(forCellWith: indexPath)
        attributes.indexPath = indexPath
        let frame = self.frame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = self.actualItemSize
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView, let bannerView = self.bannerView else {
            return proposedContentOffset
        }
        
        var proposedContentOffset = proposedContentOffset
        
        func calculateTargetOffset(by proposedOffset: CGFloat, boundedOffset: CGFloat) -> CGFloat {
            var targetOffset: CGFloat
            if bannerView.decelerationDistance == JSBannerView.automaticDistance {
                if abs(velocity.x) >= 0.3 {
                    let vector: CGFloat = velocity.x >= 0 ? 1.0 : -1.0
                    targetOffset = round(proposedOffset / self.itemSpacing + 0.35 * vector) * self.itemSpacing
                }
                else {
                    targetOffset = round(proposedOffset / self.itemSpacing) * self.itemSpacing
                }
            }
            else {
                let extraDistance = max(bannerView.decelerationDistance - 1, 0)
                switch velocity.x {
                case 0.3 ... CGFloat.greatestFiniteMagnitude :
                    targetOffset = ceil(collectionView.contentOffset.x / self.itemSpacing + CGFloat(extraDistance)) * self.itemSpacing
                case -(CGFloat.greatestFiniteMagnitude) ... -0.3 :
                    targetOffset = floor(collectionView.contentOffset.x / self.itemSpacing - CGFloat(extraDistance)) * self.itemSpacing
                default:
                    targetOffset = round(proposedOffset / self.itemSpacing) * self.itemSpacing
                }
            }
            targetOffset = max(0.0, targetOffset)
            targetOffset = min(boundedOffset, targetOffset)
            return targetOffset
        }
        
        let proposedContentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return proposedContentOffset.x
            }
            let boundedOffset = collectionView.contentSize.width - self.itemSpacing
            return calculateTargetOffset(by: proposedContentOffset.x, boundedOffset: boundedOffset)
        }()
        let proposedContentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return proposedContentOffset.y
            }
            let boundedOffset = collectionView.contentSize.height - self.itemSpacing
            return calculateTargetOffset(by: proposedContentOffset.y, boundedOffset: boundedOffset)
        }()
        
        proposedContentOffset = CGPoint(x: proposedContentOffsetX, y: proposedContentOffsetY)
        
        return proposedContentOffset
    }
    
    // MARK:
    func forceInvalidate() {
        self.needsReprepare = true
        self.invalidateLayout()
    }
    
    func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        guard let collectionView = self.collectionView else {
            return origin
        }
        let contentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return 0.0
            }
            let contentOffsetX = origin.x - (collectionView.frame.width * 0.5 - self.actualItemSize.width * 0.5)
            return contentOffsetX
        }()
        let contentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return 0.0
            }
            let contentOffsetY = origin.y - (collectionView.frame.height * 0.5 - self.actualItemSize.height * 0.5)
            return contentOffsetY
        }()
        let contentOffset = CGPoint(x: contentOffsetX, y: contentOffsetY)
        return contentOffset
    }

    func frame(for indexPath: IndexPath) -> CGRect {
        let numberOfItems = self.numberOfItems * indexPath.section + indexPath.item
        let originX: CGFloat = {
            if self.scrollDirection == .vertical {
                return (self.collectionView!.frame.width - self.actualItemSize.width) * 0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems) * self.itemSpacing
        }()
        let originY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return (self.collectionView!.frame.height - self.actualItemSize.height) * 0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems) * self.itemSpacing
        }()
        let origin = CGPoint(x: originX, y: originY)
        let frame = CGRect(origin: origin, size: self.actualItemSize)
        return frame
    }

    // MARK:
    fileprivate func initialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    fileprivate func adjustCollectionViewBounds() {
        guard let collectionView = self.collectionView, let bannerView = self.bannerView else {
            return
        }
        let currentIndex = bannerView.currentIndex
        let newIndexPath = IndexPath(item: currentIndex, section: bannerView.isInfinite ? self.numberOfSections / 2 : 0)
        let contentOffset = self.contentOffset(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
    }
    
    fileprivate func applyTransform(to attributes: JSBannerViewLayoutAttributes, with transformer: JSBannerViewTransformer?) {
        guard let collectionView = self.collectionView else {
            return
        }
        guard let transformer = transformer else {
            return
        }
        switch self.scrollDirection {
        case .horizontal:
            let ruler = collectionView.bounds.midX
            attributes.position = (attributes.center.x - ruler) / self.itemSpacing
        case .vertical:
            let ruler = collectionView.bounds.midY
            attributes.position = (attributes.center.y - ruler) / self.itemSpacing
        }
        attributes.zIndex = self.numberOfItems - Int(attributes.position)
        transformer.applyTransform(to: attributes)
    }
    
    // MARK:
    @objc fileprivate func didReceiveNotification(_ notification: Notification) {
        if self.bannerView?.itemSize == .zero {
            self.adjustCollectionViewBounds()
        }
    }
}
