//
//  PageControlExampleViewController.swift
//  JSBannerView-Demo
//
//  Created by Max on 2019/4/16.
//  Copyright © 2019 Max. All rights reserved.
//

import UIKit
import JSBannerView

class PageControlExampleViewController: UIViewController {

    // MAKR:
    lazy var bannerView: JSBannerView = {
        let bannerView = JSBannerView(frame: CGRect(x: 0.0, y: self.topMargin, width: UIScreen.main.bounds.width, height: 195.0))
        bannerView.isInfinite = true
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
    fileprivate let sectionTitles = ["Style", "Item Spacing", "Inter Item Spacing", "Horizontal Alignment"]
    fileprivate let styleTitles = ["Default", "Ring", "UIImage", "UIBezierPath - Star", "UIBezierPath - Heart"]
    fileprivate let alignmentTitles = ["Right", "Center", "Left"]
    fileprivate let bannerImages = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    
    fileprivate var styleIndex = 0 {
        didSet {
            self.bannerControl.setStrokeColor(nil, for: .normal)
            self.bannerControl.setStrokeColor(nil, for: .selected)
            self.bannerControl.setFillColor(nil, for: .normal)
            self.bannerControl.setFillColor(nil, for: .selected)
            self.bannerControl.setImage(nil, for: .normal)
            self.bannerControl.setImage(nil, for: .selected)
            self.bannerControl.setPath(nil, for: .normal)
            self.bannerControl.setPath(nil, for: .selected)
            switch self.styleIndex {
            case 0:
                break
            case 1:
                self.bannerControl.setStrokeColor(.green, for: .normal)
                self.bannerControl.setStrokeColor(.green, for: .selected)
                self.bannerControl.setFillColor(.green, for: .selected)
            case 2:
                break
            case 3:
                self.bannerControl.setStrokeColor(.yellow, for: .normal)
                self.bannerControl.setStrokeColor(.yellow, for: .selected)
                self.bannerControl.setFillColor(.yellow, for: .selected)
                self.bannerControl.setPath(self.starPath, for: .normal)
                self.bannerControl.setPath(self.starPath, for: .selected)
            case 4:
                let color = UIColor(red: 255/255.0, green: 102/255.0, blue: 255/255.0, alpha: 1.0)
                self.bannerControl.setStrokeColor(color, for: .normal)
                self.bannerControl.setStrokeColor(color, for: .selected)
                self.bannerControl.setFillColor(color, for: .selected)
                self.bannerControl.setPath(self.heartPath, for: .normal)
                self.bannerControl.setPath(self.heartPath, for: .selected)
            default:
                break
            }
        }
    }
    fileprivate var alignmentIndex = 0 {
        didSet {
            self.bannerControl.contentHorizontalAlignment = [.right, .center, .left][self.alignmentIndex]
        }
    }
    
    fileprivate var starPath: UIBezierPath {
        let width = self.bannerControl.itemSpacing
        let height = self.bannerControl.itemSpacing
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: width * 0.5, y: 0))
        starPath.addLine(to: CGPoint(x: width * 0.677, y: height * 0.257))
        starPath.addLine(to: CGPoint(x: width * 0.975, y: height * 0.345))
        starPath.addLine(to: CGPoint(x: width * 0.785, y: height * 0.593))
        starPath.addLine(to: CGPoint(x: width * 0.794, y: height * 0.905))
        starPath.addLine(to: CGPoint(x: width * 0.5, y: height * 0.8))
        starPath.addLine(to: CGPoint(x: width * 0.206, y: height * 0.905))
        starPath.addLine(to: CGPoint(x: width * 0.215, y: height * 0.593))
        starPath.addLine(to: CGPoint(x: width * 0.025, y: height * 0.345))
        starPath.addLine(to: CGPoint(x: width * 0.323, y: height * 0.257))
        starPath.close()
        return starPath
    }

    fileprivate var heartPath: UIBezierPath {
        let width = self.bannerControl.itemSpacing
        let height = self.bannerControl.itemSpacing
        let heartPath = UIBezierPath()
        heartPath.move(to: CGPoint(x: width * 0.5, y: height))
        heartPath.addCurve(
            to: CGPoint(x: 0.0, y: height * 0.25),
            controlPoint1: CGPoint(x: width * 0.5, y: height * 0.75) ,
            controlPoint2: CGPoint(x: 0.0, y: height * 0.5)
        )
        heartPath.addArc(
            withCenter: CGPoint(x: width * 0.25,y: height * 0.25),
            radius: width * 0.25,
            startAngle: .pi,
            endAngle: 0.0,
            clockwise: true
        )
        heartPath.addArc(
            withCenter: CGPoint(x: width * 0.75, y: height * 0.25),
            radius: width * 0.25,
            startAngle: .pi,
            endAngle: 0.0,
            clockwise: true
        )
        heartPath.addCurve(
            to: CGPoint(x: width * 0.5, y: height),
            controlPoint1: CGPoint(x: width, y: height * 0.5),
            controlPoint2: CGPoint(x: width * 0.5, y: height * 0.75)
        )
        heartPath.close()
        return heartPath
    }

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
        case 1:
            self.bannerControl.itemSpacing = CGFloat(sender.value) * 10.0 + 6.0
            if [3, 4].contains(self.styleIndex) {
                let index = self.styleIndex
                self.styleIndex = index
            }
        case 2:
            self.bannerControl.interItemSpacing = CGFloat(sender.value) * 10.0 + 6.0
        default:
            break
        }
    }
}

extension PageControlExampleViewController: UITableViewDataSource {
    
    // MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.styleTitles.count
        case 1, 2:
            return 1
        case 3:
            return self.alignmentTitles.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = self.styleTitles[indexPath.row]
            cell.accessoryType = self.styleIndex == indexPath.row ? .checkmark : .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath)
            let slider = cell.contentView.subviews.first as! UISlider
            slider.tag = indexPath.section
            slider.value = Float((self.bannerControl.itemSpacing - 6.0) / 10.0)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath)
            let slider = cell.contentView.subviews.first as! UISlider
            slider.tag = indexPath.section
            slider.value = Float((self.bannerControl.interItemSpacing - 6.0) / 10.0)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = self.alignmentTitles[indexPath.row]
            cell.accessoryType = self.alignmentIndex == indexPath.row ? .checkmark : .none
            return cell
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
}

extension PageControlExampleViewController: UITableViewDelegate {
    
    // MARK:
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return [0, 3].contains(indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            self.styleIndex = indexPath.row
            tableView.reloadSections([indexPath.section], with: .automatic)
        case 3:
            self.alignmentIndex = indexPath.row
            tableView.reloadSections([indexPath.section], with: .automatic)
        default:
            break
        }
    }
}

extension PageControlExampleViewController: JSBannerViewDataSource {
    
    // MARK:
    func numberOfItems(in bannerView: JSBannerView) -> Int {
        return self.bannerImages.count
    }
    
    func bannerView(_ bannerView: JSBannerView, cellForItemAt index: Int) -> JSBannerViewCell {
        let cell = bannerView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: index)
        cell.imageView?.image = UIImage(named: self.bannerImages[index])
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }
}

extension PageControlExampleViewController: JSBannerViewDelegate {
    
    // MARK:
    func bannerView(_ bannerView: JSBannerView, didSelectItemAt index: Int) {
        bannerView.deselectItem(at: index, animated: true)
    }
    
    func bannerViewWillEndDragging(_ bannerView: JSBannerView, targetIndex: Int) {
        self.bannerControl.currentPage = targetIndex
    }
}
