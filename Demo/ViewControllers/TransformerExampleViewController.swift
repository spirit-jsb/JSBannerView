//
//  TransformerExampleViewController.swift
//  JSBannerView-Demo
//
//  Created by Max on 2019/4/15.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit
import JSBannerView

class TransformerExampleViewController: UIViewController {

    // MARK:
    lazy var bannerView: JSBannerView = {
        let bannerView = JSBannerView(frame: CGRect(x: 0.0, y: self.topMargin, width: UIScreen.main.bounds.width, height: 195.0))
        bannerView.isInfinite = true
        bannerView.register(JSBannerViewCell.self, forCellWithReuseIdentifier: "BannerCell")
        self.view.addSubview(bannerView)
        return bannerView
    }()
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let topMargin: CGFloat = (UIScreen.main.bounds.height == 812.0 || UIScreen.main.bounds.height == 896.0) ? 88.0 : 64.0
    fileprivate let bannerImages = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    fileprivate let transformerTitles = ["cross fading", "zoom out", "depth", "overlap", "linear", "cover flow", "ferris wheel", "inverted ferris wheel", "cubic"]
    fileprivate let transformerTypes: [JSBannerViewTransformerType] = [.crossFading, .zoomOut, .depth, .overlap, .linear, .coverFlow, .ferrisWheel, .invertedFerrisWheel, .cubic]
    fileprivate var typeIndex = 0 {
        didSet {
            let type = self.transformerTypes[self.typeIndex]
            self.bannerView.transformer = JSBannerViewTransformer(type: type)
            switch type {
            case .crossFading, .zoomOut, .depth:
                self.bannerView.itemSize = JSBannerView.automaticSize
                self.bannerView.decelerationDistance = 1
            case .linear, .overlap:
                let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
                self.bannerView.itemSize = self.bannerView.frame.size.applying(transform)
                self.bannerView.decelerationDistance = JSBannerView.automaticDistance
            case .ferrisWheel, .invertedFerrisWheel:
                self.bannerView.itemSize = CGSize(width: 180.0, height: 140.0)
                self.bannerView.decelerationDistance = JSBannerView.automaticDistance
            case .coverFlow:
                self.bannerView.itemSize = CGSize(width: 220.0, height: 170.0)
                self.bannerView.decelerationDistance = JSBannerView.automaticDistance
            case .cubic:
                let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.bannerView.itemSize = self.bannerView.frame.size.applying(transform)
                self.bannerView.decelerationDistance = 1
            }
        }
    }

    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bannerView.dataSource = self
        self.bannerView.delegate = self

        self.typeIndex = 0
    }
}

extension TransformerExampleViewController: UITableViewDataSource {
    
    // MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transformerTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransformerCell", for: indexPath)
        cell.textLabel?.text = self.transformerTitles[indexPath.row]
        cell.accessoryType = indexPath.row == self.typeIndex ? .checkmark : .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension TransformerExampleViewController: UITableViewDelegate {
    
    // MARK:
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transformers"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.typeIndex = indexPath.row
        if let visibleRows = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleRows, with: .automatic)
        }
    }
}

extension TransformerExampleViewController: JSBannerViewDataSource {
    
    // MARK:
    func numberOfItems(in bannerView: JSBannerView) -> Int {
        return self.bannerImages.count
    }
    
    func bannerView(_ bannerView: JSBannerView, cellForItemAt index: Int) -> JSBannerViewCell {
        let cell = bannerView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: index)
        cell.imageView?.image = UIImage(named: self.bannerImages[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
}

extension TransformerExampleViewController: JSBannerViewDelegate {
    
    // MARK:
    func bannerView(_ bannerView: JSBannerView, didSelectItemAt index: Int) {
        bannerView.deselectItem(at: index, animated: true)
        bannerView.scrollToItem(at: index, animated: true)
    }
}
