//
// Copyright © 2015-2018 bruce Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  DevicesView.swift
//  SmartBracelet
//
//  Created by bruce on 2020/8/28.
//  Copyright © 2020 tjd. All rights reserved.
//
	

import UIKit

class DevicesView: UIView {
    weak var currentModel: BLEModel?
    var index = Int() // 下标
    var bConnected = false
    let cardImgView = UIImageView()
    let btImgView = UIImageView()
    let cardNameLabel = UILabel()
    let batteryLabel = UILabel()
    let macLabel = UILabel() // 蓝牙地址
    let cardContainerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupUI() {
        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.clipsToBounds = true
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cardContainerView)

        // 白色容器：水平左右与父视图保持 20，垂直居中，高度 80
        cardContainerView.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(80)
        }

        cardContainerView.addSubview(cardImgView)
        cardImgView.snp.makeConstraints { make in
            make.width.equalTo(56)
            make.height.equalTo(56)
            make.centerY.equalToSuperview()
            make.leading.equalTo(16)
        }

        cardNameLabel.textColor = UIColor.text_primary
        cardNameLabel.font = UIFont.body1()
        cardNameLabel.textAlignment = .left
        cardNameLabel.backgroundColor = .white
        cardNameLabel.translatesAutoresizingMaskIntoConstraints = false

        batteryLabel.textColor = UIColor.brand
        batteryLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        batteryLabel.textAlignment = .left
        batteryLabel.backgroundColor = .white
        batteryLabel.isHidden = true
        batteryLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [cardNameLabel, batteryLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        cardContainerView.addSubview(stackView)

        // 第一行：设备名 + 电量 + 蓝牙连接状态
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cardImgView.trailingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 14)
        ])

        cardContainerView.addSubview(btImgView)
        btImgView.image = UIImage(named: "content_blueteeth_unlink")
        btImgView.snp.makeConstraints { make in
            make.width.equalTo(10)
            make.height.equalTo(15)
            make.centerY.equalTo(stackView)
            make.leading.equalTo(stackView.snp.trailing).offset(5)
        }

        // 第二行：mac 地址
        macLabel.textColor = UIColor.text_primary
        macLabel.font = UIFont.body1()
        macLabel.textAlignment = .left
        macLabel.backgroundColor = .white
        macLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.addSubview(macLabel)

        macLabel.snp.makeConstraints { make in
            make.leading.equalTo(cardImgView.snp.trailing).offset(10)
            make.top.equalTo(stackView.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
    }

    private func applyBatteryDisplay(using device: BluetoothWatchDevice?) {
        guard let device = device,
              device.isNoScreenDevice,
              let batteryLevel = device.batteryLevel else {
            batteryLabel.isHidden = true
            batteryLabel.text = nil
            return
        }
        let chargingSuffix = (device.isCharging ?? false) ? " ⚡" : ""
        batteryLabel.text = "\(batteryLevel)%\(chargingSuffix)"
        batteryLabel.textColor = batteryLevel >= 20 ? .systemGreen : .systemRed
        batteryLabel.isHidden = false
    }

    public func refreshData(value: Int? = 0) {
        DeviceManager.shared.initializeDevices()
        
        var count = DeviceManager.shared.devices.count
        count += cacheDevices.count
        // #region debug-point C:devices-card-refresh
        postSameCrashDebugEvent(
            hypothesisId: "C",
            location: "DevicesView.refreshData",
            msg: "设备卡刷新",
            data: [
                "deviceCount": DeviceManager.shared.devices.count,
                "cacheCount": cacheDevices.count,
                "lastestDeviceMac": lastestDeviceMac,
                "isConnected": bleSelf.isConnected,
                "value": value ?? -1
            ]
        )
        // #endregion
        if count == 0 {
            self.isHidden = true
        } else {
            self.isHidden = false

            if (cacheDevices.count) > 0 {
                XLogger.shared.log("Item already exists at index \(index)")
                self.isHidden = false
                cardImgView.image = UIImage(named: "icon_ewatch")
                if let device = BluetoothWatchDevice.loadFromSandbox(mac: lastestDeviceMac) {
                    cardNameLabel.text = device.deviceName ?? ""
                    if device.max == lastestDeviceMac && (device.max == XGZTBlueToothManager.shared.device?.max && XGZTBlueToothManager.shared.device != nil) {
                        if XGZTBlueToothManager.shared.centralManager?.state == .poweredOff {
                            bConnected = false
                            btImgView.image = UIImage(named: "content_blueteeth_unlink")
                        } else {
                            if value == 100 || XGZTBlueToothManager.shared.isReconnectingNow {
                                bConnected = false
                                btImgView.image = UIImage(named: "content_blueteeth_unlink")
                            } else {
                                if XGZTBlueToothManager.shared.checkConnectedDevicesIsEmpty() {
                                    bConnected = false
                                    btImgView.image = UIImage(named: "content_blueteeth_unlink")
                                } else {
                                    bConnected = true
                                    btImgView.image = UIImage(named: "content_blueteeth_link")
                                }
                            }
                            
                        }
                    } else {
                        btImgView.image = UIImage(named: "content_blueteeth_unlink")
                    }
                    macLabel.text = device.max ?? ""
                    applyBatteryDisplay(using: XGZTBlueToothManager.shared.device ?? device)
                    return
                }
                let deviceName = XGZTBlueToothManager.shared.getDeviceName(mac: lastestDeviceMac)
                if deviceName.count > 0 {
                    cardNameLabel.text = deviceName
                    if lastestDeviceMac == XGZTBlueToothManager.shared.device?.max && XGZTBlueToothManager.shared.device != nil {
                        if XGZTBlueToothManager.shared.centralManager?.state == .poweredOff {
                            bConnected = false
                            btImgView.image = UIImage(named: "content_blueteeth_unlink")
                        } else {
                            if value == 100 || XGZTBlueToothManager.shared.isReconnectingNow {
                                bConnected = false
                                btImgView.image = UIImage(named: "content_blueteeth_unlink")
                            } else {
                                if XGZTBlueToothManager.shared.checkConnectedDevicesIsEmpty() {
                                    bConnected = false
                                    btImgView.image = UIImage(named: "content_blueteeth_unlink")
                                } else {
                                    bConnected = true
                                    btImgView.image = UIImage(named: "content_blueteeth_link")
                                }
                            }
                            
                        }
                    } else {
                        btImgView.image = UIImage(named: "content_blueteeth_unlink")
                    }
                    macLabel.text = lastestDeviceMac
                    applyBatteryDisplay(using: XGZTBlueToothManager.shared.device)
                    return
                }
            }
            
            currentModel = nil
            if count > 0 {
                for item in DeviceManager.shared.devices {
                    
                    if item.mac == lastestDeviceMac {
                        currentModel = item
                        break
                    }
                }
            }
            
            if currentModel == nil {
                self.isHidden = true
            } else {
                self.isHidden = false
                cardImgView.image = UIImage(named: AppDelegate.IsDeviceNotRound() ? "icon_ewatch" : "icon_ewatch_2")
                if let metrics = AppDelegate.resolvedDeviceScreenMetrics() {
                    cardNameLabel.text = (currentModel?.name ?? "") + " - \(metrics.width)*\(metrics.height)"
                } else {
                    cardNameLabel.text = currentModel?.name ?? ""
                }
                if currentModel!.mac == lastestDeviceMac && bleSelf.isConnected {
                    if XGZTBlueToothManager.shared.centralManager?.state == .poweredOff {
                        bConnected = false
                        btImgView.image = UIImage(named: "content_blueteeth_unlink")
                    } else {
                        if value == 100 || XGZTBlueToothManager.shared.isReconnectingNow {
                            bConnected = false
                            btImgView.image = UIImage(named: "content_blueteeth_unlink")
                        } else {
                            bConnected = true
                            btImgView.image = UIImage(named: "content_blueteeth_link")
                        }
                    }
                    
                } else {
                    btImgView.image = UIImage(named: "content_blueteeth_unlink")
                }
                macLabel.text = currentModel?.mac ?? ""
                batteryLabel.isHidden = true
                batteryLabel.text = nil
            }
        }
    }
}
