//
//  XGZTSwitchDevice.swift
//  SmartBracelet
//
//  Created by  bruce on 2024/11/15.
//  Copyright © 2024 tjd. All rights reserved.
//

import Foundation

public var cacheDevices = [BluetoothWatchDevice]()

public class BluetoothWatchDevice {
    // 手表设备信息属性
    var deviceName: String?
    var deviceModel: Int?
    var deviceID: Int?
    var brandID: Int? // 品牌id
    var max: String?
    var batteryLevel: Int?
    var isCharging: Bool?
    var deviceLanguage: Int?
    var deviceUnitFormat: Int?
    /// 硬件版本
    var hardwareVersion: Int?
    /// 固件版本
    var firmwareVersion: String?
    /// 自定义：屏幕形状: 0x00: 正方形, 0x01: 圆形, 0x02: 长方形
    var screenType: Int = 1
    /// 表盘宽 默认240
    var screenWidth: Int = 240
    /// 表盘高 默认240
    var screenHeight: Int = 240
    var mtu: Int = 0
    
    var sex: Int = 0 // 性别：0x00：男，0x01：女
    var age: Int = 0
    var height: Int = 0
    var weight: Int = 0
    var timeUnit: Int = 0 // 返回时间制：0x00:12h 0x01:24h
    var baseUnit: Int = 0
    
    var alarmcount: Int = 0
    var alarmCanUse: Int = 0
    var alarms: [AlarmData] = [] // 闹钟
    var longsit: ReminderInfoResponse?
    var drinkWater: ReminderInfoResponse?
    
    // 健康相关数据
    var currentStep: Int = 0
    var currentSleep: Int = 0
    var currentCalorie: Int = 0
    var currentDistance: Int = 0
    var currentHeartrate: Int = 0
    var currentOxygen: Int = 0
    var currentSystolicpressure: Int = 0 // 收缩压（单位：mmHg）
    var currentDiastolicpressure: Int = 0 // 舒张压（单位：mmHg）
    
    var functioncontrolflags: Int = 0 // [0] 是否支持表盘市场 [1] 是否支持消息提醒 [2] 是否支持天气功能 等
    var healthcontrolflags: Int = 0 // [0] 是否支持心率检测 [1] 是否支持血氧检测 等
    
    // 开关类
    var isAntilostSwitch: Bool = false // 防丢开关
    var isRaisehandtobrightenscreen: Bool = false // 抬手亮屏开关
    var isAutoSyncSwitch: Bool = false // 自动同步开关
    var isSleepmonitoringSwitch: Bool = false // 睡眠监测开关
    var isMessageremindermainswitch: Bool = false // 消息提醒总开关
    var isRegularexercisedatauploadswitch: Bool = false // 整点上传运动数据开关
    var isGoalachievementswitch: Bool = false // 目标达成开关
    var isMessagescreendisplayswitch: Bool = false // 消息提醒亮屏开关
    var isSoundswitch: Bool = false // 声音开关
    var isVibrationswitch: Bool = false // 震动总开关
    var isRegularhealthdatauploadswitch: Bool = false // 整点上传健康数据开关
    var isMessagevibrationswitch: Bool = false // 消息提醒震动开关
    
    // 通知类
    var isNullMessage: Bool = true // 无消息
    var isIncomingCall: Bool = false // 来电
    var isMissedCall: Bool = false // 未接来电
    var isMessages: Bool = true // 短信
    var isEmail: Bool = true // 邮件
    var isSchedule: Bool = true // 日程
    var isFacetime: Bool = true // Facetime
    var isQQ: Bool = true // qq
    var isSkype: Bool = true // Skype
    var isWechat: Bool = true // Wechat
    var isWhatsapp: Bool = true // Whatsapp
    var isGmail: Bool = true // Gmail
    var isHangout: Bool = true // Hangout
    var isInbox: Bool = true // Inbox
    var isLine: Bool = true // Line
    var isTwitter: Bool = true
    var isFacebook: Bool = true
    var isFacebookMessenger: Bool = true
    var isInstagram: Bool = true
    var isWeibo: Bool = true
    var isKakaotalk: Bool = true
    var isFacebookpagemanager: Bool = true
    var isViber: Bool = true
    var isVkclient: Bool = true
    var isTelegram: Bool = true
    var isSnapchat: Bool = true
    var isDingTalk: Bool = true
    var isAlipay: Bool = true
    var isTiktok: Bool = true
    var isLinkedIn: Bool = true
    
    
    // 存储设备信息到沙盒
    static func saveToSandbox(device: BluetoothWatchDevice) {
        let defaults = UserDefaults.standard
        
        // 安全解包mac地址，确保键有效
        guard let macAddress = device.max, !macAddress.isEmpty else {
            XLogger.shared.log("Error: device.max (mac address) is nil or empty")
            return
        }
        
        // 安全解包设备名称，确保不存储空值
        guard let deviceName = device.deviceName, !deviceName.isEmpty else {
            XLogger.shared.log("Error: deviceName is nil or empty for mac address \(macAddress)")
            return
        }
        
        var dic = defaults.dictionary(forKey: "xgzt") as? [String: String] ?? [:]
        
        // 检查该mac地址是否已存在且值相同
        if let existingName = dic[macAddress], existingName == deviceName {
            return // 名称相同，无需更新
        }
        
        // 存储当前设备的键值对
        dic[macAddress] = deviceName
        defaults.set(dic, forKey: "xgzt")
        
        // 更新缓存
        loadAll()
    }
    
    
    // 从沙盒读取设备信息
    static func loadFromSandbox(mac: String) -> BluetoothWatchDevice? {
        let defaults = UserDefaults.standard
        let dic = defaults.dictionary(forKey: "xgzt") as? [String: String] ?? [:]
        
        guard let name = dic[mac] else {
            return nil
        }
        
        let device = BluetoothWatchDevice()
        device.deviceName = name
        device.max = mac
        return device
    }
    
    // 新增：从沙盒读取指定设备名称的设备信息
    // 如果存在多个同名设备，返回第一个匹配项
    static func loadFromSandbox(deviceName: String) -> BluetoothWatchDevice? {
        let defaults = UserDefaults.standard
        let dic = defaults.dictionary(forKey: "xgzt") as? [String: String] ?? [:]
        
        // 遍历查找名称匹配的设备
        for (mac, name) in dic {
            if name == deviceName {
                let device = BluetoothWatchDevice()
                device.deviceName = name
                device.max = mac
                return device
            }
        }
        
        // 未找到匹配的设备
        return nil
    }
    
    // 从沙盒删除指定mac地址的设备信息
    static func deleteFromSandbox(mac: String) {
        let defaults = UserDefaults.standard
        guard var dic = defaults.dictionary(forKey: "xgzt") as? [String: String], !dic.isEmpty else {
            return
        }
        
        // 直接移除指定mac的记录
        if dic.removeValue(forKey: mac) != nil {
            XLogger.shared.log("删除设备 \(mac) 成功")
            defaults.set(dic, forKey: "xgzt")
            defaults.synchronize()
            loadAll() // 更新缓存
        } else {
            XLogger.shared.log("未找到设备 \(mac)，无需删除")
        }
    }
    
    // 清除沙盒中所有"xgzt"相关数据
    static func clearAllXgztData() {
        let defaults = UserDefaults.standard
        // 移除"xgzt"对应的所有数据
        defaults.removeObject(forKey: "xgzt")
        defaults.synchronize()
        // 清空缓存
        cacheDevices.removeAll()
        XLogger.shared.log("已清除所有xgzt相关数据")
    }
    
    // 加载所有设备信息到缓存
    static func loadAll() {
        cacheDevices.removeAll()
        let defaults = UserDefaults.standard
        
        guard let dic = defaults.dictionary(forKey: "xgzt") as? [String: String], !dic.isEmpty else {
            return
        }
        
        var existingMACs = Set<String>() // 用于去重
        
        for (mac, name) in dic {
            // 跳过空值或重复的MAC地址
            guard !mac.isEmpty, !existingMACs.contains(mac) else {
                continue
            }
            
            existingMACs.insert(mac)
            
            let device = BluetoothWatchDevice()
            device.deviceName = name
            device.max = mac
            XLogger.shared.log("已缓存设备：\(mac) \(name)")
            cacheDevices.append(device)
        }
    }
}
