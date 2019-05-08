//
//  RxBannerExampleViewController.swift
//  JSBannerView
//
//  Created by Max on 2019/5/8.
//  Copyright © 2019 Max. All rights reserved.
//

import Foundation
import JSBannerView
import RxSwift
import RxCocoa

struct SegmentTemplateModel: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case title
        case image
        case highlightedImage
        case action
        case badge
    }
    
    var title: String
    var image: String
    var highlightedImage: String
    var action: String
    var badge: Int
}

struct RxBannerCustomData {
    
    // MARK: 属性
    var items: [Item]
}

extension RxBannerCustomData: BannerModelType {
    
    // MARK: SegmentModelType
    typealias Item = String
    
    init(original: RxBannerCustomData, items: [Item]) {
        self = original
        self.items = items
    }
}

class RxBannerExampleViewController: UIViewController {
    
    // MARK:
    lazy var bannerView: JSBannerView = {
        let bannerView = JSBannerView(frame: CGRect(x: 0.0, y: self.topMargin, width: UIScreen.main.bounds.width, height: 195.0))
        bannerView.isInfinite = true
        bannerView.removesInfiniteLoopForSingleItem = true
        bannerView.automaticSlidingInterval = 3.0
        bannerView.alwaysBounceHorizontal = true
        bannerView.register(JSBannerViewCell.self, forCellWithReuseIdentifier: "BannerCell")
        return bannerView
    }()
    lazy var bannerControl: JSBannerControl = {
        let bannerControl = JSBannerControl(frame: CGRect(x: 0.0, y: 170.0, width: UIScreen.main.bounds.width, height: 25.0))
        bannerControl.hideForSinglePage = true
        bannerControl.numberOfPages = self.bannerImages.count
        bannerControl.contentHorizontalAlignment = .right
        bannerControl.contentInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        return bannerControl
    }()
    
    fileprivate let topMargin: CGFloat = (UIScreen.main.bounds.height == 812.0 || UIScreen.main.bounds.height == 896.0) ? 88.0 : 64.0
    fileprivate let bannerImages = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    
    private var dataSource: RxBannerReloadDataSource<RxBannerCustomData>!
    private var bag: DisposeBag = DisposeBag()
        
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.bannerView)
        self.bannerView.addSubview(self.bannerControl)
        
        let bannerCustomData: Observable<RxBannerCustomData> = Observable<RxBannerCustomData>.just(RxBannerCustomData(items: self.bannerImages))
        
        self.dataSource = RxBannerReloadDataSource<RxBannerCustomData>.init(configureCell: {
            (ds, bv, i, item) -> JSBannerViewCell in
            let cell = bv.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: i)
            cell.imageView?.image = UIImage(named: item)
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.clipsToBounds = true
            cell.textLabel?.text = i.description + i.description
            return cell
        })
        
        self.bannerView.rx.setDelegate(self)
            .disposed(by: self.bag)
        
        bannerCustomData.bind(to: self.bannerView.rx.item(dataSource: self.dataSource))
            .disposed(by: self.bag)
    }
}

extension RxBannerExampleViewController: JSBannerViewDelegate {
    
    // MARK:
    func bannerView(_ bannerView: JSBannerView, didSelectItemAt index: Int) {
        bannerView.deselectItem(at: index, animated: true)
        bannerView.scrollToItem(at: index, animated: true)
    }
    
    func bannerViewWillEndDragging(_ bannerView: JSBannerView, targetIndex: Int) {
        self.bannerControl.currentPage = targetIndex
    }
    
    func bannerViewDidEndScrollAnimation(_ bannerView: JSBannerView) {
        self.bannerControl.currentPage = bannerView.currentIndex
    }
}
