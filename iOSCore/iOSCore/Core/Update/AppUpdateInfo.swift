//
//  AppUpdateInfo.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation

/// 应用更新信息
public struct AppUpdateInfo: Codable {
    /// 最新版本号（如 "1.2.0"）
    public let version: String
    /// 弹窗标题
    public let title: String?
    /// 更新日志
    public let message: String?
    /// 是否强制更新
    public let forceUpdate: Bool
    /// 下载/追踪 URL
    public let action: String?

    private enum CodingKeys: String, CodingKey {
        case version, title, message, forceUpdate, action
    }
}
