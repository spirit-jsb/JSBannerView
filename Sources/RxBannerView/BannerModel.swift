//
//  BannerModel.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation

public struct BannerModel<ItemType> {
    
    public var items: [Item]
    
    public init(items: [Item]) {
        self.items = items
    }
}

extension BannerModel: BannerModelType {
    
    public typealias Item = ItemType
    
    public init(original: BannerModel<ItemType>, items: [ItemType]) {
        self = original
        self.items = items
    }
}

extension BannerModel: CustomStringConvertible {
    
    public var description: String {
        return "\(self.items)"
    }
}
