//
//  AppUpdateApi.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import Foundation

/// 应用更新 API
public final class AppUpdateApi {

    /// API Host（可配置）
    public var apiHost: String = "https://update.kakamobi.com"

    /// 签名 Key（可配置）
    public var signKey: String = ""

    /// API 路径
    public var apiPath: String = "/api/open/v4/update/check.htm"

    public init() {}

    /// 检查更新
    /// - Parameter channel: 渠道标识
    /// - Returns: 更新信息（nil 表示无更新）
    public func checkUpdate(channel: String = "") async throws -> AppUpdateInfo? {
        var parameters: [String: String] = [
            "bundleId": AppInfo.bundleIdentifier,
            "appVersion": AppInfo.bundleVersion,
            "systemVersion": DeviceInfo.systemVersion,
            "deviceModel": DeviceInfo.deviceModel,
        ]
        if !channel.isEmpty {
            parameters["channel"] = channel
        }

        let url = apiHost + apiPath
        let params = parameters.mapValues { $0 as Any }

        let data: Data = try await NetworkManager.shared.get(url, parameters: params)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // 尝试解析响应
        struct UpdateResponse: Codable {
            let code: Int?
            let data: AppUpdateInfo?
        }

        let response = try decoder.decode(UpdateResponse.self, from: data)
        return response.data
    }
}
