//
// Copyright © 2015-2018 bruce Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  MarketClockViewController.swift
//  SmartBracelet
//
//  Created by bruce on 2020/9/5.
//  Copyright © 2020 tjd. All rights reserved.
//
	

import UIKit
import Toaster
import ProgressHUD
import Alamofire

class MarketClockViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var rightButton: UIButton!
    var bShowDetail = false
    var current = 0
    var marketModel: MarketClockResponse? // 从后台读取到的数据
    var clockArray: [ClockResponse] = [] // 指定分辨率的数组
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if bShowDetail == false {
            rightButton = UIButton(type: .custom).then {
                $0.initializeRightNavigationItem()
                $0.setTitle("mine_manage".localized(), for: .normal)
                $0.setTitle("mine_delete".localized(), for: .selected)
                $0.setTitle("mine_finish".localized(), for: .disabled)
                $0.frame = CGRect(x: 0, y: 0, width: 60, height: 24)
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        }
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        downloadClock() // 下载资源
        
        // 2列布局，统一间距体系：16pt 左右边距，12pt 列间距
        let sectionInset: CGFloat = 16
        let spacing: CGFloat = 12
        width = (ScreenWidth - sectionInset * 2 - spacing) / 2
        if AppDelegate.IsDeviceNotRound() { // 方形
            let w = bleSelf.bleModel.screenWidth
            let h = bleSelf.bleModel.screenHeight
            height = CGFloat(width) * CGFloat(h) / CGFloat(w)
        } else { // 圆形
            height =  width
        }
        XLogger.shared.log("width: \(width) height: \(height)")
    }
    
    private func downloadClock() {
        ProgressHUD.animate(nil, .activityIndicator, interaction: false)
        var w = bleSelf.bleModel.screenWidth
        var h = bleSelf.bleModel.screenHeight
        var firmNo = bleSelf.isJLBlue ? "JieLi" : "FengJiaWei"
        let bk = bleSelf.bleModel.internalNumber.hasPrefix("5A4B") // 是否为中科
        if bk {
            firmNo = "ZhongKe"
        }
        if isXGZT {
            firmNo = "ZhongKe_S"
            w = XGZTBlueToothManager.shared.device?.screenWidth ?? 0
            h = XGZTBlueToothManager.shared.device?.screenHeight ?? 0
        }
        let parameters = ["pageSize": "100", "pageNum": "1", "isPublish": "Y", "resolutionRatio": "\(w)*\(h)", "firmNo": firmNo]
        AF.request("https://u-watch.com.cn/api/app/dial/list?pageSize=100&pageNum=1&firmNo=\(firmNo)", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).response { [weak self] (response) in
            debugPrint("Request: \((String(data:response.request?.httpBody ?? Data(),encoding:.utf8) ?? "")) Response: \(response.debugDescription)")
            ProgressHUD.dismiss()
            guard let data = response.value as? Data else {
                return
            }
            XLogger.shared.log("返回的数据：\(data)")
            // MarketClockResponse
            let model = try? JSONDecoder().decode(MarketClockResponse.self, from: data)
            if model == nil {
                Toast(text: "解析失败").show()
                return
            }
            self?.clockArray = model?.rows?.filter { $0.resolutionRatio == "\(w)*\(h)" } ?? []
            self?.collectionView.reloadData()
            
        }
    }

}

extension MarketClockViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clockArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .kCellIdentifier, for: indexPath) as! ClockCCollectionViewCell
        let item = clockArray[indexPath.row]
        cell.clockImageView.kf.setImage(with: URL(string: item.previewPic ?? ""))
        cell.opaqueView.layer.cornerRadius = AppDelegate.IsDeviceNotRound() ? 30 : width / 2
        cell.opaqueView.clipsToBounds = true
        cell.width.constant = width
        cell.height.constant = height
        
        // 卡片样式：背景色、圆角、阴影
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        
        return cell
    }
    
}

extension MarketClockViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !bleSelf.isConnected && XGZTBlueToothManager.shared.device == nil {
            Toast(text: "mine_unconnect".localized()).show()
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "ClockUseViewController") as? ClockUseViewController
        vc?.index = indexPath.row + 1 // 代表什么含义
        vc?.current = current
        vc?.currentClock = clockArray[indexPath.row]
        parent?.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // 统一间距体系：12pt 上下内边距，16pt 左右内边距
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // 行间距：12pt
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // 列间距：12pt
        return 12
    }
}

