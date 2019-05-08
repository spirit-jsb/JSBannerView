//
//  RxBannerReloadDataSource.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class RxBannerReloadDataSource<S: BannerModelType>: BannerDataSource<S>, RxBannerDataSourceType {
    
    public typealias Element = S
    
    open func bannerView(_ bannerView: JSBannerView, observedEvent: Event<S>) {
        Binder(self) { dataSource, element in
            #if DEBUG
            self._dataSourceBound = true
            #endif
            dataSource.setBanner(element)
            bannerView.reloadData()
        }
        .on(observedEvent)
    }
}
