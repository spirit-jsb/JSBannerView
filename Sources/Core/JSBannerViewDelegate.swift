//
//  JSBannerViewDelegate.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation

@objc public protocol JSBannerViewDelegate: NSObjectProtocol {
    
    @objc optional func bannerView(_ bannerView: JSBannerView, shouldHighlightItemAt index: Int) -> Bool
    
    @objc optional func bannerView(_ bannerView: JSBannerView, didHighlightItemAt index: Int)
    
    @objc optional func bannerView(_ bannerView: JSBannerView, shouldSelectItemAt index: Int) -> Bool
    
    @objc optional func bannerView(_ bannerView: JSBannerView, didSelectItemAt index: Int)
    
    @objc optional func bannerView(_ bannerView: JSBannerView, willDisplay cell: JSBannerViewCell, forItemAt index: Int)
    
    @objc optional func bannerView(_ bannerView: JSBannerView, didEndDisplaying cell: JSBannerViewCell, forItemAt index: Int)
    
    @objc optional func bannerViewWillBeginDragging(_ bannerView: JSBannerView)
    
    @objc optional func bannerViewWillEndDragging(_ bannerView: JSBannerView, targetIndex: Int)
    
    @objc optional func bannerViewDidScroll(_ bannerView: JSBannerView)
    
    @objc optional func bannerViewDidEndScrollAnimation(_ bannerView: JSBannerView)
    
    @objc optional func bannerViewDidEndDecelerating(_ bannerView: JSBannerView)
}
