//
//  AppInfo.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/10.
//

import Foundation

/// 应用信息收集
public struct AppInfo {

    // MARK: - Bundle 信息

    /// Bundle Identifier
    public static let bundleIdentifier: String = Bundle.main.bundleIdentifier ?? ""

    /// 版本号（CFBundleShortVersionString）
    public static let bundleVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

    /// 构建版本号（CFBundleVersion）
    public static let bundleBuildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

    /// 显示名称
    public static let bundleDisplayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""

    /// Bundle Name
    public static let bundleName: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""

    // MARK: - 启动相关

    private static let launchDefaults = UserDefaults.standard
    private static let firstLaunchKey = "com.ioscore.isFirstLaunch"
    private static let firstLaunchTimeKey = "com.ioscore.firstLaunchTime"
    private static let launchCountKey = "com.ioscore.launchCount"

    /// 是否首次启动
    public static let isFirstLaunch: Bool = {
        if launchDefaults.bool(forKey: firstLaunchKey) {
            return false
        }
        return true
    }()

    /// 首次启动时间（格式 yyyy-MM-dd HH:mm:ss）
    public static let firstLaunchTime: String? = {
        if isFirstLaunch {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timeString = formatter.string(from: Date())
            launchDefaults.set(timeString, forKey: firstLaunchTimeKey)
            launchDefaults.set(true, forKey: firstLaunchKey)
            return timeString
        }
        return launchDefaults.string(forKey: firstLaunchTimeKey)
    }()

    /// 启动次数（每次 +1）
    public static var launchCount: Int {
        let count = launchDefaults.integer(forKey: launchCountKey) + 1
        launchDefaults.set(count, forKey: launchCountKey)
        return count
    }

    // MARK: - 安装时间

    /// 首次安装时间（Documents 目录创建时间）
    public static let installDate: Date? = {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: documentsURL.path)
            return attributes[.creationDate] as? Date
        } catch {
            return nil
        }
    }()

    /// 更新安装时间（Info.plist 文件修改时间）
    public static let updateInstallDate: Date? = {
        guard let infoPlistURL = Bundle.main.url(forResource: "Info", withExtension: "plist") else {
            return nil
        }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: infoPlistURL.path)
            return attributes[.modificationDate] as? Date
        } catch {
            return nil
        }
    }()
}
