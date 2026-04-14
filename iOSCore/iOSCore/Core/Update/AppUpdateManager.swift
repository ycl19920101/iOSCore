//
//  AppUpdateManager.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 应用更新管理器
public final class AppUpdateManager {

    public static let shared = AppUpdateManager()

    private let api = AppUpdateApi()

    /// 上次检查到的新版本信息
    public private(set) var lastUpdateInfo: AppUpdateInfo?

    private init() {}

    // MARK: - 配置

    /// 配置 API Host
    @discardableResult
    public func apiHost(_ host: String) -> Self {
        api.apiHost = host
        return self
    }

    /// 配置签名 Key
    @discardableResult
    public func signKey(_ key: String) -> Self {
        api.signKey = key
        return self
    }

    /// 配置 API 路径
    @discardableResult
    public func apiPath(_ path: String) -> Self {
        api.apiPath = path
        return self
    }

    // MARK: - 检查更新

    /// 自动检查更新（App 启动时调用）
    /// - Parameter channel: 渠道标识
    public func autoCheckUpdate(channel: String = "") {
        Task {
            guard let info = try? await api.checkUpdate(channel: channel) else { return }
            guard hasNewVersion(info.version) else { return }
            lastUpdateInfo = info
            await showUpdateAlert(info: info)
        }
    }

    /// 手动检查更新（用户触发）
    /// - Parameter channel: 渠道标识
    /// - Returns: 更新信息
    @discardableResult
    public func manualCheckUpdate(channel: String = "") -> Task<AppUpdateInfo?, Never> {
        Task {
            guard let info = try? await api.checkUpdate(channel: channel) else { return nil }
            if hasNewVersion(info.version) {
                lastUpdateInfo = info
                await showUpdateAlert(info: info)
            }
            return info
        }
    }

    // MARK: - 版本比较

    /// 比较版本号，判断是否有新版本
    public func hasNewVersion(_ remoteVersion: String) -> Bool {
        let current = AppInfo.bundleVersion
        return compareVersion(current, remoteVersion) == .orderedAscending
    }

    /// 版本号比较
    /// - Returns: .orderedAscending 表示 v1 < v2
    public func compareVersion(_ v1: String, _ v2: String) -> ComparisonResult {
        let parts1 = v1.split(separator: ".").compactMap { Int($0) }
        let parts2 = v2.split(separator: ".").compactMap { Int($0) }

        let maxCount = max(parts1.count, parts2.count)
        for i in 0..<maxCount {
            let p1 = i < parts1.count ? parts1[i] : 0
            let p2 = i < parts2.count ? parts2[i] : 0
            if p1 < p2 { return .orderedAscending }
            if p1 > p2 { return .orderedDescending }
        }
        return .orderedSame
    }

    // MARK: - 显示更新弹窗

    @MainActor
    private func showUpdateAlert(info: AppUpdateInfo) {
        guard let viewController = ViewUtils.topViewController() else { return }

        let title = info.title ?? "发现新版本"
        let message = info.message ?? "v\(info.version) 已发布，请更新至最新版本。"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if info.forceUpdate {
            // 强制更新：只显示更新按钮，不可关闭
            alert.addAction(UIAlertAction(title: "立即更新", style: .default) { _ in
                self.openUpdateURL(info.action)
            })
        } else {
            // 非强制更新：可跳过
            alert.addAction(UIAlertAction(title: "稍后再说", style: .cancel))
            alert.addAction(UIAlertAction(title: "立即更新", style: .default) { _ in
                self.openUpdateURL(info.action)
            })
        }

        viewController.present(alert, animated: true)
    }

    private func openUpdateURL(_ urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            // 默认打开 App Store
            let appStoreID = ""
            if let storeURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)") {
                UIApplication.shared.open(storeURL)
            }
            return
        }
        UIApplication.shared.open(url)
    }
}
