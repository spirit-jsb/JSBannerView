//
//  BasicExampleViewController.swift
//  JSBannerView-Demo
//
//  Created by Max on 2019/4/16.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit
import JSBannerView

class BasicExampleViewController: UIViewController {
    
    // MARK:
    lazy var bannerView: JSBannerView = {
        let bannerView = JSBannerView(frame: CGRect(x: 0.0, y: self.topMargin, width: UIScreen.main.bounds.width, height: 195.0))
        bannerView.isInfinite = true
        bannerView.removesInfiniteLoopForSingleItem = true
        bannerView.alwaysBounceHorizontal = true
        bannerView.register(JSBannerViewCell.self, forCellWithReuseIdentifier: "BannerCell")
        self.view.addSubview(bannerView)
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
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let topMargin: CGFloat = (UIScreen.main.bounds.height == 812.0 || UIScreen.main.bounds.height == 896.0) ? 88.0 : 64.0
    fileprivate let sectionTitles = ["Configurations", "Decelaration Distance", "Item Size", "Inter Item Spacing", "Number Of Items"]
    fileprivate let configurationTitles = ["Automatic sliding", "Infinite"]
    fileprivate let decelarationDistanceTitles = ["Automatic", "1", "2"]
    fileprivate let bannerImages = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    
    fileprivate var numberOfItems = 7
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bannerView.dataSource = self
        self.bannerView.delegate = self
        
        self.bannerView.addSubview(self.bannerControl)
    }
    
    // MARK:
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 2:
            let newScale = 0.5 + CGFloat(sender.value) * 0.5
            self.bannerView.itemSize = self.bannerView.frame.size.applying(CGAffineTransform(scaleX: newScale, y: newScale))
        case 3:
            self.bannerView.interItemSpacing = CGFloat(sender.value) * 20.0
        case 4:
            self.numberOfItems = Int(roundf(sender.value * 7))
            self.bannerControl.numberOfPages = self.numberOfItems
            self.bannerView.reloadData()
        default:
            break
        }
    }
}

extension BasicExampleViewController: UITableViewDataSource {
    
    // MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.configurationTitles.count
        case 1:
            return self.decelarationDistanceTitles.count
        case 2, 3, 4:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = self.configurationTitles[indexPath.row]
            if indexPath.row == 0 {
                cell.accessoryType = self.bannerView.automaticSlidingInterval > 0.0 ? .checkmark : .none
            }
            else if indexPath.row == 1 {
                cell.accessoryType = self.bannerView.isInfinite ? .checkmark : .none
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = self.decelarationDistanceTitles[indexPath.row]
            switch indexPath.row {
            case 0:
                cell.accessoryType = self.bannerView.decelerationDistance == JSBannerView.automaticDistance ? .checkmark : .none
            case 1:
                cell.accessoryType = self.bannerView.decelerationDistance == 1 ? .checkmark : .none
            case 2:
                cell.accessoryType = self.bannerView.decelerationDistance == 2 ? .checkmark : .none
            default:
                break
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath)
            let slider = cell.contentView.subviews.first as! UISlider
            slider.tag = 2
            slider.value = {
                let scale = self.bannerView.itemSize.width / self.bannerView.frame.width
                let value = (0.5 - scale) * 2.0
                return Float(value)
            }()
            slider.isContinuous = true
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath)
            let slider = cell.contentView.subviews.first as! UISlider
            slider.tag = 3
            slider.value = Float(self.bannerView.interItemSpacing / 20.0)
            slider.isContinuous = true
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath)
            let slider = cell.contentView.subviews.first as! UISlider
            slider.tag = 4
            slider.minimumValue = 1.0 / 7.0
            slider.maximumValue = 1.0
            slider.value = Float(self.numberOfItems / 7)
            slider.isContinuous = false
            return cell
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
}

extension BasicExampleViewController: UITableViewDelegate {
    
    // MARK:
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 || indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                self.bannerView.automaticSlidingInterval = 3.0 - self.bannerView.automaticSlidingInterval
            }
            else if indexPath.row == 1 {
                self.bannerView.isInfinite = !self.bannerView.isInfinite
            }
            tableView.reloadSections([indexPath.section], with: .automatic)
        case 1:
            switch indexPath.row {
            case 0:
                self.bannerView.decelerationDistance = JSBannerView.automaticDistance
            case 1:
                self.bannerView.decelerationDistance = 1
            case 2:
                self.bannerView.decelerationDistance = 2
            default:
                break
            }
            tableView.reloadSections([indexPath.section], with: .automatic)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40.0 : 20.0
    }
}

extension BasicExampleViewController: JSBannerViewDataSource {
    
    // MARK:
    func numberOfItems(in bannerView: JSBannerView) -> Int {
        return self.numberOfItems
    }
    
    func bannerView(_ bannerView: JSBannerView, cellForItemAt index: Int) -> JSBannerViewCell {
        let cell = bannerView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: index)
        cell.imageView?.image = UIImage(named: self.bannerImages[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = index.description + index.description
        return cell
    }
}

extension BasicExampleViewController: JSBannerViewDelegate {
    
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
