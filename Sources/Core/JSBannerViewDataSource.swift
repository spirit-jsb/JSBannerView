//
//  JSBannerViewDataSource.swift
//  JSBannerView
//
//  Created by Max on 2019/4/12.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation

public protocol JSBannerViewDataSource: NSObjectProtocol {
    
    func numberOfItems(in bannerView: JSBannerView) -> Int
    
    func bannerView(_ bannerView: JSBannerView, cellForItemAt index: Int) -> JSBannerViewCell
}
