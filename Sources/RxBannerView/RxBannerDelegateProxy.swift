//
//  RxBannerDelegateProxy.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

///// For more information take a look at `DelegateProxyType`.
open class RxBannerDelegateProxy: DelegateProxy<JSBannerView, JSBannerViewDelegate>, DelegateProxyType, JSBannerViewDelegate {
    
    /// Typed parent object.
    public weak private(set) var banner: JSBannerView?
    
    /// - parameter banner: Parent object for delegate proxy.
    public init(banner: JSBannerView) {
        self.banner = banner
        super.init(parentObject: banner, delegateProxy: RxBannerDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxBannerDelegateProxy(banner: $0) }
    }
    
    public static func currentDelegate(for object: JSBannerView) -> JSBannerViewDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: JSBannerViewDelegate?, to object: JSBannerView) {
        object.delegate = delegate
    }
}
