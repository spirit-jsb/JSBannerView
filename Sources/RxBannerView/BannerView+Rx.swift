//
//  BannerView+Rx.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: JSBannerView {
    
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy<JSBannerView, JSBannerViewDelegate> {
        return RxBannerDelegateProxy.proxy(for: self.base)
    }
    
    public func item<DataSource: RxBannerDataSourceType & JSBannerViewDataSource, O: ObservableType>
        (dataSource: DataSource)
        -> (_ source: O)
        -> Disposable where DataSource.Element == O.Element
    {
        return { source in
            // This is called for sideeffects only, and to make sure delegate proxy is in place when
            // data source is being bound.
            // This is needed because theoretically the data source subscription itself might
            // call `self.rx.delegate`. If that happens, it might cause weird side effects since
            // setting data source will set delegate, and JSSegmentControl might get into a weird state.
            // Therefore it's better to set delegate proxy first, just to be sure.
            _ = self.delegate
            // Strong reference is needed because data source is in use until result subscription is disposed
            return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource as JSBannerViewDataSource, retainDataSource: true, binding: { [weak banner = self.base] (_: RxBannerDataSourceProxy, event) in
                guard let banner = banner else {
                    return
                }
                dataSource.bannerView(banner, observedEvent: event)
            })
        }
    }
    
    public func setDelegate(_ delegate: JSBannerViewDelegate) -> Disposable {
        return RxBannerDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}

extension ObservableType {
    
    func subscribeProxyDataSource<DelegateProxy: DelegateProxyType>
        (ofObject object: DelegateProxy.ParentObject,
         dataSource: DelegateProxy.Delegate,
         retainDataSource: Bool,
         binding: @escaping (DelegateProxy, Event<Element>) -> Void)
        -> Disposable where DelegateProxy.ParentObject: UIView, DelegateProxy.Delegate: AnyObject
    {
        let proxy = DelegateProxy.proxy(for: object)
        let unregisterDelegate = DelegateProxy.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)
        // this is needed to flush any delayed old state (https://github.com/RxSwiftCommunity/RxDataSources/pull/75)
        object.layoutIfNeeded()
        
        let subscription = self.asObservable()
            .observeOn(MainScheduler())
            .catchError { error in
                self.bindingError(error)
                return Observable.empty()
            }
            // source can never end, otherwise it would release the subscriber, and deallocate the data source
            .concat(Observable.never())
            .takeUntil(object.rx.deallocated)
            .subscribe { [weak object] (event: Event<Element>) in
                if let object = object {
                    assert(proxy === DelegateProxy.currentDelegate(for: object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: DelegateProxy.currentDelegate(for: object)))")
                }
                
                binding(proxy, event)
                
                switch event {
                case .error(let error):
                    self.bindingError(error)
                    unregisterDelegate.dispose()
                case .completed:
                    unregisterDelegate.dispose()
                default:
                    break
                }
        }
        
        return Disposables.create { [weak object] in
            subscription.dispose()
            object?.layoutIfNeeded()
            unregisterDelegate.dispose()
        }
    }
    
    func bindingError(_ error: Swift.Error) {
        let error = "Binding error: \(error)"
        #if DEBUG
        fatalError(error)
        #else
        print(error)
        #endif
    }
}

