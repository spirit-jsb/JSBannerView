//
//  RxBannerDataSourceType.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol RxBannerDataSourceType {
    
    associatedtype Element
    
    func bannerView(_ bannerView: JSBannerView, observedEvent: Event<Element>) -> Void
}
