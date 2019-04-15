//
//  JSBannerView.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit

open class JSBannerView: UIView {
    
    // MARK:
    open weak var dataSource: JSBannerViewDataSource?
    
    open weak var delegate: JSBannerViewDelegate?
    
    open var decelerationDistance: UInt = 1
    
    open var isScrollEnabled: Bool {
        set {
            self.collectionView.isScrollEnabled = newValue
        }
        get {
            return self.collectionView.isScrollEnabled
        }
    }
    
    open var bounces: Bool {
        set {
            self.collectionView.bounces = newValue
        }
        get {
            return self.collectionView.bounces
        }
    }
    
    open var alwaysBounceHorizontal: Bool {
        set {
            self.collectionView.alwaysBounceHorizontal = newValue
        }
        get {
            return self.collectionView.alwaysBounceHorizontal
        }
    }
    
    open var alwaysBounceVertical: Bool {
        set {
            self.collectionView.alwaysBounceVertical = newValue
        }
        get {
            return self.collectionView.alwaysBounceVertical
        }
    }

    open var scrollDirection: JSBannerView.ScrollDirection = .horizontal {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    open var automaticSlidingInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.automaticSlidingInterval > 0.0 {
                self.startTimer()
            }
        }
    }
    
    open var interitemSpacing: CGFloat = 0.0 {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    open var itemSize: CGSize = JSBannerView.automaticSize {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    open var isInfinite: Bool = false {
        didSet {
            self.reloadData()
        }
    }
    
    open var removesInfiniteLoopForSingleItem: Bool = false {
        didSet {
            self.reloadData()
        }
    }
    
    open var backgroundView: UIView? {
        didSet {
            if let backgroundView = self.backgroundView {
                if backgroundView.superview != nil {
                    backgroundView.removeFromSuperview()
                }
                self.insertSubview(backgroundView, at: 0)
                self.setNeedsLayout()
            }
        }
    }
    
    open var transformer: JSBannerViewTransformer? {
        didSet {
            self.transformer?.bannerView = self
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    open var isTracking: Bool {
        return self.collectionView.isTracking
    }
    
    open var scrollOffset: CGFloat {
        let contentOffset = max(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y)
        let scrollOffset = contentOffset / self.collectionViewLayout.itemSpacing
        return fmod(scrollOffset, CGFloat(self.numberOfItems))
    }
    
    open var panGestureRecognizer: UIPanGestureRecognizer {
        return self.collectionView.panGestureRecognizer
    }
    
    open fileprivate(set) var currentIndex: Int = 0
    
    internal weak var collectionViewLayout: JSBannerViewLayout!
    internal weak var collectionView: JSBannerCollectionView!
    internal weak var contentView: UIView!
    internal var timer: Timer?
    internal var numberOfItems: Int = 0
    internal var numberOfSections: Int = 0
    
    fileprivate var dequeingSection: Int = 0
    
    fileprivate var centermostIndexPath: IndexPath {
        guard self.numberOfItems > 0, self.collectionView.contentSize != .zero else {
            return IndexPath(item: 0, section: 0)
        }
        let sortedIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted { (l, r) -> Bool in
            let leftFrame = self.collectionViewLayout.frame(for: l)
            let rightFrame = self.collectionViewLayout.frame(for: r)
            var leftCenter: CGFloat, rightCenter: CGFloat, ruler: CGFloat
            switch self.scrollDirection {
            case .horizontal:
                leftCenter = leftFrame.midX
                rightCenter = rightFrame.midX
                ruler = self.collectionView.bounds.midX
            case .vertical:
                leftCenter = leftFrame.midY
                rightCenter = rightFrame.midY
                ruler = self.collectionView.bounds.midY
            }
            return abs(ruler - leftCenter) < abs(ruler - rightCenter)
        }
        guard let indexPath = sortedIndexPaths.first else {
            return IndexPath(item: 0, section: 0)
        }
        return indexPath
    }
    
    fileprivate var isPossiblyRotating: Bool {
        guard let animationKeys = self.contentView.layer.animationKeys() else {
            return false
        }
        let rotatingAnimationKeys = ["position", "bounds.origin", "bounds.size"]
        return animationKeys.contains(where: { rotatingAnimationKeys.contains($0) })
    }
    
    fileprivate var possibleTargetingIndexPath: IndexPath?
    
    // MARK:
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil
    }
    
    // MARK:
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView?.frame = self.bounds
        self.contentView.frame = self.bounds
        self.collectionView.frame = self.contentView.bounds
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        newWindow != nil ? self.startTimer() : self.cancelTimer()
    }
    
    // MARK:
    open func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    open func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> JSBannerViewCell {
        let indexPath = IndexPath(item: index, section: self.dequeingSection)
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? JSBannerViewCell else {
            fatalError("Cell class must be subclass of JSBannerViewCell")
        }
        return cell
    }
    
    open func reloadData() {
        self.collectionViewLayout.needsReprepare = true
        self.collectionView.reloadData()
    }
    
    open func selectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    open func deselectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        self.collectionView.deselectItem(at: indexPath, animated: animated)
    }
    
    open func scrollToItem(at index: Int, animated: Bool) {
        guard index < self.numberOfItems else {
            fatalError("index \(index) is out of range [0...\(self.numberOfItems - 1)]")
        }
        let indexPath = { () -> IndexPath in
            if let indexPath = self.possibleTargetingIndexPath, indexPath.item == index {
                defer {
                    self.possibleTargetingIndexPath = nil
                }
                return indexPath
            }
            return self.numberOfSections > 1 ? self.nearbyIndexPath(for: index) : IndexPath(item: index, section: 0)
        }()
        let contentOffset = self.collectionViewLayout.contentOffset(for: indexPath)
        self.collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    open func index(for cell: JSBannerViewCell) -> Int {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return NSNotFound
        }
        return indexPath.item
    }
    
    open func cellForItem(at index: Int) -> JSBannerViewCell? {
        let indexPath = self.nearbyIndexPath(for: index)
        return self.collectionView.cellForItem(at: indexPath) as? JSBannerViewCell
    }

    // MARK:
    fileprivate func initialize() {
        let contentView = UIView(frame: .zero)
        contentView.backgroundColor = UIColor.clear
        self.addSubview(contentView)
        self.contentView = contentView
        
        let collectionViewLayout = JSBannerViewLayout()
        let collectionView = JSBannerCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        self.contentView.addSubview(collectionView)
        self.collectionView = collectionView
        self.collectionViewLayout = collectionViewLayout
    }
    
    fileprivate func startTimer() {
        guard self.automaticSlidingInterval > 0.0 && self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.automaticSlidingInterval), target: self, selector: #selector(flipNext(_:)), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    fileprivate func cancelTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer?.invalidate()
        self.timer = nil
    }
    
    fileprivate func nearbyIndexPath(for index: Int) -> IndexPath {
        let currentIndex = self.currentIndex
        let currentSection = self.centermostIndexPath.section
        if abs(currentIndex - index) <= self.numberOfItems / 2 {
            return IndexPath(item: index, section: currentSection)
        }
        else if index - currentIndex >= 0 {
            return IndexPath(item: index, section: currentSection - 1)
        }
        else {
            return IndexPath(item: index, section: currentSection + 1)
        }
    }

    // MARK:
    @objc fileprivate func flipNext(_ sender: Timer?) {
        guard let _ = self.superview, let _ = self.window, self.numberOfItems > 0, !self.isTracking else {
            return
        }
        let contentOffset: CGPoint = {
            let indexPath = self.centermostIndexPath
            let section = self.numberOfSections > 1 ? (indexPath.section + (indexPath.item + 1) / self.numberOfItems) : 0
            let item = (indexPath.item + 1) % self.numberOfItems
            return self.collectionViewLayout.contentOffset(for: IndexPath(item: item, section: section))
        }()
        self.collectionView.setContentOffset(contentOffset, animated: true)
    }
}

extension JSBannerView: UICollectionViewDataSource {
    
    // MARK:
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        self.dequeingSection = indexPath.section
        let cell = self.dataSource!.bannerView(self, cellForItemAt: index)
        return cell
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else {
            return 1
        }
        self.numberOfItems = dataSource.numberOfItems(in: self)
        guard self.numberOfItems > 0 else {
            return 0
        }
        self.numberOfSections = self.isInfinite && (self.numberOfItems > 1 || !self.removesInfiniteLoopForSingleItem) ? Int(Int16.max) / self.numberOfItems : 1
        return self.numberOfSections
    }
}

extension JSBannerView: UICollectionViewDelegate {
    
    // MARK:
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let function = self.delegate?.bannerView(_:shouldHighlightItemAt:) else {
            return true
        }
        let index = indexPath.item % self.numberOfItems
        return function(self, index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.bannerView(_:didHighlightItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self, index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let function = self.delegate?.bannerView(_:shouldSelectItemAt:) else {
            return true
        }
        let index = indexPath.item % self.numberOfItems
        return function(self, index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.bannerView(_:didSelectItemAt:) else {
            return
        }
        self.possibleTargetingIndexPath = indexPath
        defer {
            self.possibleTargetingIndexPath = nil
        }
        let index = indexPath.item % self.numberOfItems
        function(self, index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.bannerView(_:willDisplay:forItemAt:), let cell = cell as? JSBannerViewCell else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self, cell, index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.bannerView(_:didEndDisplaying:forItemAt:), let cell = cell as? JSBannerViewCell else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self, cell, index)
    }
}

extension JSBannerView: UIScrollViewDelegate {
    
    // MARK:
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isPossiblyRotating && self.numberOfItems > 0 {
            let currentIndex = lround(Double(self.scrollOffset)) % self.numberOfItems
            if currentIndex != self.currentIndex {
                self.currentIndex = currentIndex
            }
        }
        guard let function = self.delegate?.bannerViewDidScroll(_:) else {
            return
        }
        function(self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let function = self.delegate?.bannerViewWillBeginDragging(_:) {
            function(self)
        }
        if self.automaticSlidingInterval > 0 {
            self.cancelTimer()
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let function = self.delegate?.bannerViewWillEndDragging(_:targetIndex:) {
            let contentOffset = self.scrollDirection == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y
            let targetItem = lround(Double(contentOffset / self.collectionViewLayout.itemSpacing))
            function(self, targetItem % self.numberOfItems)
        }
        if self.automaticSlidingInterval > 0 {
            self.startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let function = self.delegate?.bannerViewDidEndDecelerating(_:) {
            function(self)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let function = self.delegate?.bannerViewDidEndScrollAnimation(_:) {
            function(self)
        }
    }
}

extension JSBannerView {
    
    public enum ScrollDirection: Int {
        case horizontal
        case vertical
    }
    
    public static let automaticDistance: UInt = 0
    
    public static let automaticSize: CGSize = .zero
}
