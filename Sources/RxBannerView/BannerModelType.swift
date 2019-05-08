//
//  BannerModelType.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation

public protocol BannerModelType {
    
    associatedtype Item
    
    var items: [Item] { get }
    
    init(items: [Item])
}
