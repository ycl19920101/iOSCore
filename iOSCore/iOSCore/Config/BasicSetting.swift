//
//  BasicSetting.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/10.
//

import Foundation

/// 全局参数管理器，线程安全
public final class BasicSetting {

    public static let shared = BasicSetting()

    // MARK: - 通知

    /// 参数变化通知
    public static let settingChangedNotification = Notification.Name("BasicSettingChanged")

    // MARK: - 私有属性

    private let queue = DispatchQueue(label: "com.ioscore.basicsetting", attributes: .concurrent)

    private var appParameters: [String: String] = [:]
    private var deviceParameters: [String: String] = [:]
    private var userParameters: [String: String] = [:]
    private var configParameters: [String: String] = [:]

    /// 隐私参数开关
    public private(set) var privacyEnabled: Bool = false

    /// 是否已初始化
    private var isBuilt = false

    private init() {}

    // MARK: - 初始化

    /// 构建基础参数，只能调用一次
    public func build() {
        _ = queue.sync(flags: .barrier) {
            guard !isBuilt else { return }
            isBuilt = true

            appParameters = [
                "bundleId": AppInfo.bundleIdentifier,
                "appVersion": AppInfo.bundleVersion,
                "appBuildVersion": AppInfo.bundleBuildVersion,
                "appName": AppInfo.bundleDisplayName,
                "isFirstLaunch": AppInfo.isFirstLaunch ? "1" : "0",
                "firstLaunchTime": AppInfo.firstLaunchTime ?? "",
                "launchCount": "\(AppInfo.launchCount)",
            ]

            if let installDate = AppInfo.installDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                appParameters["installDate"] = formatter.string(from: installDate)
            }

            if let updateDate = AppInfo.updateInstallDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                appParameters["updateInstallDate"] = formatter.string(from: updateDate)
            }

            deviceParameters = [
                "systemName": DeviceInfo.systemName,
                "systemVersion": DeviceInfo.systemVersion,
                "deviceModel": DeviceInfo.deviceModel,
                "manufacturer": DeviceInfo.manufacturer,
                "screenWidth": "\(Int(DeviceInfo.screenWidth))",
                "screenHeight": "\(Int(DeviceInfo.screenHeight))",
                "screenScale": "\(DeviceInfo.screenScale)",
                "screenDPI": "\(DeviceInfo.screenDPI)",
                "networkType": DeviceInfo.networkType,
                "isJailbroken": DeviceInfo.isJailbroken ? "1" : "0",
                "yclUUID": DeviceInfo.yclUUID,
            ]

            if let carrier = DeviceInfo.carrierName {
                deviceParameters["carrierName"] = carrier
            }
        }
    }

    // MARK: - 读取

    /// 获取指定 key 的参数值
    public func setting(forKey key: String) -> String? {
        queue.sync {
            if let value = configParameters[key] { return value }
            if let value = userParameters[key] { return value }
            if let value = deviceParameters[key] { return value }
            return appParameters[key]
        }
    }

    /// 获取所有公共参数（合并四层：dynamic → config → user → device → app）
    public func parameters() -> [String: String] {
        queue.sync {
            var result: [String: String] = [:]

            // 第一层：app
            result.merge(appParameters) { _, new in new }

            // 第二层：device
            result.merge(deviceParameters) { _, new in new }

            // 第三层：user
            result.merge(userParameters) { _, new in new }

            // 第四层：config
            result.merge(configParameters) { _, new in new }

            // 第五层：动态参数（隐私相关，仅在启用后收集）
            if privacyEnabled {
                result["idfa"] = DeviceInfo.idfa
            }

            return result
        }
    }

    // MARK: - User 参数（运行时动态添加/删除）

    /// 添加用户参数
    public func appendUserParameter(_ value: String, forKey key: String) {
        queue.sync(flags: .barrier) {
            userParameters[key] = value
        }
        notifyChanged()
    }

    /// 移除用户参数
    public func removeUserParameter(forKey key: String) {
        queue.sync(flags: .barrier) {
            userParameters.removeValue(forKey: key)
        }
        notifyChanged()
    }

    // MARK: - Config 参数

    /// 添加配置参数
    public func appendConfigParameter(_ value: String, forKey key: String) {
        queue.sync(flags: .barrier) {
            configParameters[key] = value
        }
        notifyChanged()
    }

    /// 移除配置参数
    public func removeConfigParameter(forKey key: String) {
        queue.sync(flags: .barrier) {
            configParameters.removeValue(forKey: key)
        }
        notifyChanged()
    }

    // MARK: - 隐私

    /// 开启隐私参数收集（IDFA、定位等）
    public func enablePrivacy() {
        _ = queue.sync(flags: .barrier) {
            privacyEnabled = true
        }
        notifyChanged()
    }

    // MARK: - 通知

    private func notifyChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: BasicSetting.settingChangedNotification, object: self)
        }
    }
}
