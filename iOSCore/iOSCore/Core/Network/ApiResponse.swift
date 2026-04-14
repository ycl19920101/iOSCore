//
//  ApiResponse.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation

/// 通用 API 响应模型
public struct ApiResponse<T: Codable>: Codable {
    /// 状态码
    public let code: Int
    /// 消息
    public let message: String?
    /// 数据
    public let data: T?

    /// 是否成功（约定 code == 0 为成功）
    public var isSuccess: Bool {
        code == 0
    }

    private enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "msg"
        case data = "data"
    }
}

/// 分页数据
public struct PageData<T: Codable>: Codable {
    /// 数据列表
    public let list: [T]
    /// 当前页码
    public let page: Int?
    /// 每页数量
    public let pageSize: Int?
    /// 总数
    public let total: Int?

    private enum CodingKeys: String, CodingKey {
        case list, page, pageSize, total
    }
}
