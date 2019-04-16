//
//  JSBannerViewCell.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit

open class JSBannerViewCell: UICollectionViewCell {
    
    // MARK:
    open var textLabel: UILabel? {
        if let _ = self.textLabel_ {
            return self.textLabel_
        }
        
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.isUserInteractionEnabled = false
        self.contentView.addSubview(view)
        
        let textLabel = UILabel(frame: .zero)
        textLabel.textColor = .white
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.addObserver(self, forKeyPath: "font", options: [.old, .new], context: self.kvoContext)
        view.addSubview(textLabel)

        self.textLabel_ = textLabel
        
        return textLabel
    }
    
    open var imageView: UIImageView? {
        if let _ = self.imageView_ {
            return self.imageView_
        }
        
        let imageView = UIImageView(frame: .zero)
        self.contentView.addSubview(imageView)

        self.imageView_ = imageView
        
        return imageView
    }
    
    fileprivate weak var textLabel_: UILabel?
    fileprivate weak var imageView_: UIImageView?
    fileprivate weak var selectedForegroundView_: UIView?
    
    fileprivate let kvoContext = UnsafeMutableRawPointer(bitPattern: 0)
    fileprivate let selectionColor = UIColor(white: 0.2, alpha: 0.2)
    
    fileprivate var selectedForegroundView: UIView? {
        guard self.selectedForegroundView_ == nil else {
            return self.selectedForegroundView_
        }
        guard let imageView = self.imageView_ else {
            return nil
        }
        
        let view = UIView(frame: imageView.bounds)
        imageView.addSubview(view)
        
        self.selectedForegroundView_ = view
        
        return view
    }
    
    // MARK:
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let textLabel = self.textLabel_ {
            textLabel.removeObserver(self, forKeyPath: "font", context: self.kvoContext)
        }
    }
    
    // MAKR:
    open override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            if newValue {
                self.selectedForegroundView?.layer.backgroundColor = self.selectionColor.cgColor
            }
            else if !super.isSelected {
                self.selectedForegroundView?.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        get {
            return super.isHighlighted
        }
    }
    
    open override var isSelected: Bool {
        set {
            super.isSelected = newValue
            self.selectedForegroundView?.layer.backgroundColor = newValue ? self.selectionColor.cgColor : UIColor.clear.cgColor
        }
        get {
            return super.isSelected
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = self.imageView_ {
            imageView.frame = self.contentView.bounds
        }
        if let textLabel = self.textLabel_ {
            textLabel.superview!.frame = {
                var rect = self.contentView.bounds
                let height = textLabel.font.pointSize * 1.5
                rect.size.height = height
                rect.origin.y = self.contentView.frame.height - height
                return rect
            }()
            textLabel.frame = {
                var rect = textLabel.superview!.bounds
                rect = rect.insetBy(dx: 8.0, dy: 0.0)
                rect.size.height -= 1.0
                rect.origin.y += 1.0
                return rect
            }()
        }
        if let selectedForegroundView = self.selectedForegroundView_ {
            selectedForegroundView.frame = self.contentView.bounds
        }
    }
    
    // MAKR:
    fileprivate func initialize() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowRadius = 5.0
        self.contentView.layer.shadowOpacity = 0.75
        self.contentView.layer.shadowOffset = .zero
    }
    
    // MARK:
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == self.kvoContext {
            if keyPath == "font" {
                self.setNeedsLayout()
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
