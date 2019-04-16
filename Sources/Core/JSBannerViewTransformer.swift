//
//  JSBannerViewTransformer.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit

open class JSBannerViewTransformer: NSObject {

    // MARK:
    open internal(set) weak var bannerView: JSBannerView?
    open internal(set) var type: JSBannerViewTransformerType
    
    open var minimumScale: CGFloat = 0.65
    open var minimumAlpha: CGFloat = 0.60
    
    // MARK:
    public init(type: JSBannerViewTransformerType) {
        self.type = type
        switch type {
        case .zoomOut:
            self.minimumScale = 0.85
        case .depth:
            self.minimumScale = 0.50
        default:
            break
        }
    }
    
    // MARK:
    open func proposedInterItemSpacing() -> CGFloat {
        guard let bannerView = self.bannerView else {
            return 0.0
        }
        let scrollDirection = bannerView.scrollDirection
        switch self.type {
        case .overlap:
            guard scrollDirection == .horizontal else {
                return 0.0
            }
            return bannerView.itemSize.width * -(self.minimumScale) * 0.6
        case .linear:
            guard scrollDirection == .horizontal else {
                return 0.0
            }
            return bannerView.itemSize.width * -(self.minimumScale) * 0.2
        case .coverFlow:
            guard scrollDirection == .horizontal else {
                return 0.0
            }
            return -(bannerView.itemSize.width) * sin(.pi * 0.25 * 0.25 * 3.0)
        case .ferrisWheel, .invertedFerrisWheel:
            guard scrollDirection == .horizontal else {
                return 0.0
            }
            return -(bannerView.itemSize.width) * 0.15
        case .cubic:
            return 0.0
        default:
            break
        }
        return bannerView.interitemSpacing
    }
    
    open func applyTransform(to attributes: JSBannerViewLayoutAttributes) {
        guard let bannerView = self.bannerView else {
            return
        }
        let position = attributes.position
        let scrollDirection = bannerView.scrollDirection
        let itemSpacing = (scrollDirection == .horizontal ? attributes.bounds.width : attributes.bounds.height) + self.proposedInterItemSpacing()
        switch self.type {
        case .crossFading:
            var alpha: CGFloat = 0.0
            var zIndex = 0
            var transform = CGAffineTransform.identity
            switch scrollDirection {
            case .horizontal:
                transform.tx = -(itemSpacing) * position
            case .vertical:
                transform.ty = -(itemSpacing) * position
            }
            if abs(position) < 1.0 {
                alpha = 1.0 - abs(position)
                zIndex = 1
            }
            else {
                alpha = 0.0
                zIndex = Int.min
            }
            attributes.alpha = alpha
            attributes.zIndex = zIndex
            attributes.transform = transform
        case .zoomOut:
            var alpha: CGFloat = 0.0
            var transform = CGAffineTransform.identity
            switch position {
            case -(CGFloat.greatestFiniteMagnitude) ..< -1.0 :
                alpha = 0.0
            case -1.0 ... 1.0 :
                let scaleFactor = max(self.minimumScale, 1.0 - abs(position))
                transform.a = scaleFactor
                transform.d = scaleFactor
                switch scrollDirection {
                case .horizontal:
                    let vertMargin = attributes.bounds.height * (1.0 - scaleFactor) / 2.0
                    let horiMargin = itemSpacing * (1.0 - scaleFactor) / 2.0
                    transform.tx = position < 0.0 ? (horiMargin - vertMargin * 2.0) : (-(horiMargin) + vertMargin * 2.0)
                case .vertical:
                    let horiMargin = attributes.bounds.width * (1.0 - scaleFactor) / 2.0
                    let vertMargin = itemSpacing * (1.0 - scaleFactor) / 2.0
                    transform.ty = position < 0.0 ? (vertMargin - horiMargin * 2.0) : (-(vertMargin) + horiMargin * 2.0)
                }
                alpha = self.minimumAlpha + (scaleFactor - self.minimumScale) / (1.0 - self.minimumScale) * (1.0 - self.minimumAlpha)
            case 1.0 ... CGFloat.greatestFiniteMagnitude :
                alpha = 0.0
            default:
                break
            }
            attributes.alpha = alpha
            attributes.transform = transform
        case .depth:
            var alpha: CGFloat = 0.0
            var zIndex = 0
            var transform = CGAffineTransform.identity
            switch position {
            case -(CGFloat.greatestFiniteMagnitude) ..< -1.0 :
                alpha = 0.0
                zIndex = 0
            case -1.0 ... 0.0 :
                alpha = 1.0
                zIndex = 1
                transform.tx = 0.0
                transform.a = 1.0
                transform.d = 1.0
            case 0.0 ..< 1.0 :
                alpha = 1.0 - position
                switch scrollDirection {
                case .horizontal:
                    transform.tx = itemSpacing * -(position)
                case .vertical:
                    transform.ty = itemSpacing * -(position)
                }
                let scaleFactor = self.minimumScale + (1.0 - self.minimumScale) * (1.0 - abs(position))
                transform.a = scaleFactor
                transform.d = scaleFactor
                zIndex = 0
            case 1.0 ... CGFloat.greatestFiniteMagnitude :
                alpha = 0.0
                zIndex = 0
            default:
                break
            }
            attributes.alpha = alpha
            attributes.zIndex = zIndex
            attributes.transform = transform
        case .overlap, .linear:
            guard scrollDirection == .horizontal else {
                return
            }
            let scale = max(1.0 - (1.0 - self.minimumScale) * abs(position), self.minimumScale)
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            attributes.transform = transform
            let alpha = self.minimumAlpha + (1.0 - abs(position)) * (1.0 - self.minimumAlpha)
            attributes.alpha = alpha
            let zIndex = Int((1.0 - abs(position)) * 10.0)
            attributes.zIndex = zIndex
        case .coverFlow:
            guard scrollDirection == .horizontal else {
                return
            }
            let position = min(max(-(position), -1.0), 1.0)
            let rotation = sin(position * .pi * 0.5) * .pi * 0.25 * 1.5
            let translationZ = -(itemSpacing) * 0.5 * abs(position)
            var transform3D = CATransform3DIdentity
            transform3D.m34 = -0.002
            transform3D = CATransform3DRotate(transform3D, rotation, 0.0, 1.0, 0.0)
            transform3D = CATransform3DTranslate(transform3D, 0.0, 0.0, translationZ)
            attributes.zIndex = 100 - Int(abs(position))
            attributes.transform3D = transform3D
        case .ferrisWheel, .invertedFerrisWheel:
            guard scrollDirection == .horizontal else {
                return
            }
            var zIndex = 0
            var transform = CGAffineTransform.identity
            switch position {
            case -5.0 ... 5.0 :
                let itemSpacing = attributes.bounds.width + self.proposedInterItemSpacing()
                let count: CGFloat = 14.0
                let circle: CGFloat = .pi * 2.0
                let radius = itemSpacing * count / circle
                let ty = radius * (self.type == .ferrisWheel ? 1.0 : -1.0)
                let theta = circle / count
                let rotation = position * theta * (self.type == .ferrisWheel ? 1.0 : -1.0)
                transform = transform.translatedBy(x: -(position) * itemSpacing, y: ty)
                transform = transform.rotated(by: rotation)
                transform = transform.translatedBy(x: 0.0, y: -ty)
                zIndex = Int(4.0 - abs(position) * 10.0)
            default:
                break
            }
            attributes.alpha = abs(position) < 0.5 ? 1.0 : self.minimumAlpha
            attributes.zIndex = zIndex
            attributes.transform = transform
        case .cubic:
            switch position {
            case -(CGFloat.greatestFiniteMagnitude) ... -1 :
                attributes.alpha = 0.0
            case -1 ..< 1 :
                attributes.alpha = 1.0
                attributes.zIndex = Int((1.0 - position) * 10.0)
                let direction: CGFloat = position < 0.0 ? 1.0 : -1.0
                let theta = position * .pi * 0.5 * (scrollDirection == .horizontal ? 1.0 : -1.0)
                let radius = scrollDirection == .horizontal ? attributes.bounds.width : attributes.bounds.height
                var transform3D = CATransform3DIdentity
                transform3D.m34 = -0.002
                switch scrollDirection {
                case .horizontal:
                    attributes.center.x += direction * radius * 0.5
                    transform3D = CATransform3DRotate(transform3D, theta, 0.0, 1.0, 0.0)
                    transform3D = CATransform3DTranslate(transform3D, -(direction) * radius * 0.5, 0.0, 0.0)
                case .vertical:
                    attributes.center.y += direction * radius * 0.5
                    transform3D = CATransform3DRotate(transform3D, theta, 1.0, 0.0, 0.0)
                    transform3D = CATransform3DTranslate(transform3D, 0.0, -(direction) * radius * 0.5, 0.0)
                }
                attributes.transform3D = transform3D
            case 1.0 ... CGFloat.greatestFiniteMagnitude :
                attributes.alpha = 0.0
            default:
                attributes.alpha = 0.0
                attributes.zIndex = 0
            }
        }
    }
}
