//
//  YCLRequestInterceptor.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Alamofire
import Foundation

/// YCL 请求拦截器（注入公共参数和 Header）
public class YCLRequestInterceptor: RequestInterceptor {

    /// 是否附加 BasicSetting 公共参数
    public var attachBasicParameters: Bool = true

    /// 自定义 Header
    public var customHeaders: [String: String] = [:]

    /// 参数签名闭包
    public var parameterSigner: ((inout Parameters) -> Void)?

    public init() {}

    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest

        // 注入自定义 Header
        for (key, value) in customHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        completion(.success(request))
    }

    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        completion(.doNotRetry)
    }
}

// MARK: - NetworkManager 扩展：注入公共参数

extension NetworkManager {
    /// 创建带公共参数的请求参数
    func mergedParameters(_ parameters: Parameters?) -> Parameters {
        var merged: Parameters = attachBasicParameters
            ? BasicSetting.shared.parameters().mapValues { $0 as Any }
            : [:]
        if let parameters = parameters {
            merged.merge(parameters) { _, new in new }
        }
        return merged
    }
}
