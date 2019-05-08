//
//  RxBannerDataSourceProxy.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension JSBannerView: HasDataSource {
    public typealias DataSource = JSBannerViewDataSource
}

let bannerDataSourceNotSet = BannerDataSourceNotSet()

final class BannerDataSourceNotSet: NSObject, JSBannerViewDataSource {
    
    func numberOfItems(in bannerView: JSBannerView) -> Int {
        return 0
    }
    
    func bannerView(_ bannerView: JSBannerView, cellForItemAt index: Int) -> JSBannerViewCell {
        fatalError("DataSource not set", file: #file, line: #line)
    }
}

open class RxBannerDataSourceProxy: DelegateProxy<JSBannerView, JSBannerViewDataSource>, DelegateProxyType, JSBannerViewDataSource {
    
    /// Typed parent object.
    public weak private(set) var banner: JSBannerView?
    
    /// - parameter banner: Parent object for delegate proxy.
    public init(banner: JSBannerView) {
        self.banner = banner
        super.init(parentObject: banner, delegateProxy: RxBannerDataSourceProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxBannerDataSourceProxy(banner: $0) }
    }
    
    fileprivate weak var _requiredMethodsDataSource: JSBannerViewDataSource? = bannerDataSourceNotSet
    
    // MARK: JSBannerViewDataSource
    
    /// Required delegate method implementation.
    public func numberOfItems(in bannerView: JSBannerView) -> Int {
        return (self._requiredMethodsDataSource ?? bannerDataSourceNotSet).numberOfItems(in: bannerView)
    }
    
    /// Required delegate method implementation.
    public func bannerView(_ bannerView: JSBannerView, cellForItemAt index: Int) -> JSBannerViewCell {
        return (self._requiredMethodsDataSource ?? bannerDataSourceNotSet).bannerView(bannerView, cellForItemAt: index)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    open override func setForwardToDelegate(_ delegate: JSBannerViewDataSource?, retainDelegate: Bool) {
        self._requiredMethodsDataSource = delegate ?? bannerDataSourceNotSet
        super.setForwardToDelegate(delegate, retainDelegate: retainDelegate)
    }
}
