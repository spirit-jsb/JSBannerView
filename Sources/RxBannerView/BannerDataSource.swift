//
//  BannerDataSource.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class BannerDataSource<S: BannerModelType>: NSObject, JSBannerViewDataSource {
    
    public typealias I = S.Item
    
    public typealias ConfigureCell = (BannerDataSource<S>, JSBannerView, Int, I) -> JSBannerViewCell
    
    public init(configureCell: @escaping ConfigureCell) {
        self.configureCell = configureCell
    }
    
    #if DEBUG
    // If data source has already been bound, then mutating it
    // afterwards isn't something desired.
    // This simulates immutability after binding
    var _dataSourceBound: Bool = false
    
    private func ensureNotMutatedAfterBinding() {
        assert(!self._dataSourceBound, "Data source is already bound. Please write this line before binding call (`bindTo`, `drive`). Data source must first be completely configured, and then bound after that, otherwise there could be runtime bugs, glitches, or partial malfunctions.")
    }
    #endif
    
    private var _bannerModel: BannerModel<I> = BannerModel<I>(items: [])
    
    open var bannerModel: BannerModel<I> {
        return self._bannerModel
    }
    
    open subscript(index: Int) -> I {
        set(item) {
            self._bannerModel.items[index] = item
        }
        get {
            return self._bannerModel.items[index]
        }
    }
    
    open func setBanner(_ banner: S) {
        self._bannerModel = BannerModel<I>(items: banner.items)
    }
    
    open var configureCell: ConfigureCell {
        didSet {
            #if DEBUG
            self.ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    // MARK: JSBannerViewDataSource
    open func numberOfItems(in bannerView: JSBannerView) -> Int {
        return self._bannerModel.items.count
    }
    
    open func bannerView(_ bannerView: JSBannerView, cellForItemAt index: Int) -> JSBannerViewCell {
        precondition(index < self._bannerModel.items.count)
        return self.configureCell(self, bannerView, index, self[index])
    }
}
