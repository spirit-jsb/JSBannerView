//
//  JSBannerControl.swift
//  JSBannerView
//
//  Created by Max on 2019/4/15.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit

open class JSBannerControl: UIControl {

    // MARK:
    open var numberOfPages: Int = 0 {
        didSet {
            self.setNeedsUpdateIndicators()
        }
    }
    
    open var currentPage: Int = 0 {
        didSet {
            self.setNeedsUpdateIndicators()
        }
    }
    
    open var itemSpacing: CGFloat = 6.0 {
        didSet {
            self.setNeedsUpdateIndicators()
        }
    }
    
    open var interItemSpacing: CGFloat = 6.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var contentInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var hideForSinglePage: Bool = false {
        didSet {
            self.setNeedsUpdateIndicators()
        }
    }
    
    var strokeColors: [UIControl.State: UIColor] = [:]
    var fillColors: [UIControl.State: UIColor] = [:]
    var paths: [UIControl.State: UIBezierPath] = [:]
    var images: [UIControl.State: UIImage] = [:]
    var alphas: [UIControl.State: CGFloat] = [:]
    var transforms: [UIControl.State: CGAffineTransform] = [:]
    
    fileprivate weak var contentView: UIView!
    
    fileprivate var needsCreateIndicators: Bool = false
    fileprivate var needsUpdateIndicators: Bool = false
    fileprivate var indicatorLayers: [CAShapeLayer] = []
    
    // MARK:
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    open override var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = {
            let x = self.contentInsets.left
            let y = self.contentInsets.top
            let width = self.frame.width - self.contentInsets.left - self.contentInsets.right
            let height = self.frame.height - self.contentInsets.top - self.contentInsets.bottom
            let frame = CGRect(x: x, y: y, width: width, height: height)
            return frame
        }()
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let diameter = self.itemSpacing
        let spacing = self.interItemSpacing
        var x: CGFloat = {
            switch self.contentHorizontalAlignment {
            case .left, .leading:
                return 0.0
            case .center, .fill:
                let midX = self.contentView.bounds.midX
                let amplitude = diameter * CGFloat(self.numberOfPages / 2) + spacing * CGFloat((self.numberOfPages - 1) / 2)
                return midX - amplitude
            case .right, .trailing:
                let contentWidth = diameter * CGFloat(self.numberOfPages) + spacing * CGFloat(self.numberOfPages - 1)
                return self.contentView.frame.width - contentWidth
            }
        }()
        for (index, value) in self.indicatorLayers.enumerated() {
            let state: UIControl.State = (index == self.currentPage) ? .selected : .normal
            let image = self.images[state]
            let size = image?.size ?? CGSize(width: diameter, height: diameter)
            let origin = CGPoint(x: x - (size.width - diameter) * 0.5, y: self.contentView.bounds.midY - size.height * 0.5)
            value.frame = CGRect(origin: origin, size: size)
            x = x + spacing + diameter
        }
    }
    
    // MARK:
    open func setStrokeColor(_ strokeColor: UIColor?, for state: UIControl.State) {
        guard self.strokeColors[state] != strokeColor else {
            return
        }
        self.strokeColors[state] = strokeColor
        self.setNeedsUpdateIndicators()
    }
    
    open func setFillColor(_ fillColor: UIColor?, for state: UIControl.State) {
        guard self.fillColors[state] != fillColor else {
            return
        }
        self.fillColors[state] = fillColor
        self.setNeedsUpdateIndicators()
    }
    
    open func setPath(_ path: UIBezierPath?, for state: UIControl.State) {
        guard self.paths[state] != path else {
            return
        }
        self.paths[state] = path
        self.setNeedsUpdateIndicators()
    }
    
    open func setImage(_ image: UIImage?, for state: UIControl.State) {
        guard self.images[state] != image else {
            return
        }
        self.images[state] = image
        self.setNeedsUpdateIndicators()
    }
    
    open func setAlpha(_ aplha: CGFloat, for state: UIControl.State) {
        guard self.alphas[state] != alpha else {
            return
        }
        self.alphas[state] = alpha
        self.setNeedsUpdateIndicators()
    }

    // MARK:
    fileprivate func initialize() {
        self.isUserInteractionEnabled = false
        
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        self.addSubview(view)
        
        self.contentView = view
    }
    
    fileprivate func setNeedsUpdateIndicators() {
        self.needsUpdateIndicators = true
        self.setNeedsLayout()
        DispatchQueue.main.async {
            self.updateIndicatorsIfNecessary()
        }
    }
    
    fileprivate func updateIndicatorsIfNecessary() {
        guard self.needsUpdateIndicators else {
            return
        }
        guard self.indicatorLayers.count > 0 else {
            return
        }
        self.needsUpdateIndicators = false
        self.contentView.isHidden = self.hideForSinglePage && self.numberOfPages <= 1
        if !self.contentView.isHidden {
            self.indicatorLayers.forEach { (layer) in
                layer.isHidden = false
                self.updateIndicatorAttributes(for: layer)
            }
        }
    }
    
    fileprivate func updateIndicatorAttributes(for layer: CAShapeLayer) {
        let index = self.indicatorLayers.index(of: layer)
        let state: UIControl.State = index == self.currentPage ? .selected : .normal
        if let image = self.images[state] {
            layer.strokeColor = nil
            layer.fillColor = nil
            layer.path = nil
            layer.contents = image.cgImage
        }
        else {
            layer.contents = nil
            let strokeColor = self.strokeColors[state]
            let fillColor = self.fillColors[state]
            if strokeColor == nil && fillColor == nil {
                layer.fillColor = (state == .selected ? UIColor.white : UIColor.gray).cgColor
                layer.strokeColor = nil
            }
            else {
                layer.strokeColor = strokeColor?.cgColor
                layer.fillColor = fillColor?.cgColor
            }
            layer.path = self.paths[state]?.cgPath ?? UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: self.itemSpacing, height: self.itemSpacing)).cgPath
        }
        if let transform = self.transforms[state] {
            layer.transform = CATransform3DMakeAffineTransform(transform)
        }
        layer.opacity = Float(self.alphas[state] ?? 1.0)
    }
    
    fileprivate func setNeedsCreateIndicators() {
        self.needsCreateIndicators = true
        DispatchQueue.main.async {
            self.createIndicatorsIfNecessary()
        }
    }
    
    fileprivate func createIndicatorsIfNecessary() {
        guard self.needsCreateIndicators else {
            return
        }
        self.needsCreateIndicators = false
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if self.currentPage >= self.numberOfPages {
            self.currentPage = self.numberOfPages - 1
        }
        self.indicatorLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        self.indicatorLayers.removeAll()
        for _ in 0..<self.numberOfPages {
            let layer = CAShapeLayer()
            layer.actions = ["bounds": NSNull()]
            self.contentView.layer.addSublayer(layer)
            self.indicatorLayers.append(layer)
        }
        self.setNeedsUpdateIndicators()
        self.updateIndicatorsIfNecessary()
        CATransaction.commit()
    }
}

extension UIControl.State: Hashable {
    
    // MARK:
    public var hashValue: Int {
        return Int((6777 * self.rawValue + 3777) % UInt(UInt16.max))
    }
}
