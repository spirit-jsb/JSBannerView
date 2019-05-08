//
//  JSBannerViewDataSource.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation

@objc public protocol JSBannerViewDataSource: NSObjectProtocol {
    
    @objc func numberOfItems(in bannerView: JSBannerView) -> Int
    
    @objc func bannerView(_ bannerView: JSBannerView, cellForItemAt index: Int) -> JSBannerViewCell
}
