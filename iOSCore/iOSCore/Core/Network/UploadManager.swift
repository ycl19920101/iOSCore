//
//  UploadManager.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Alamofire
import Foundation

/// 上传进度信息
public struct UploadProgress {
    /// 已上传字节
    public let bytesSent: Int64
    /// 总字节
    public let totalBytes: Int64
    /// 进度 0.0 ~ 1.0
    public let fraction: Double
}

/// 上传管理器
public final class UploadManager {

    public static let shared = UploadManager()

    private init() {}

    // MARK: - 上传图片

    /// 上传图片（multipart/form-data）
    /// - Parameters:
    ///   - url: 上传地址
    ///   - imageData: 图片数据
    ///   - fileName: 文件名
    ///   - mimeType: MIME 类型（默认 image/jpeg）
    ///   - parameters: 附加参数
    ///   - headers: 请求头
    ///   - progress: 进度回调
    /// - Returns: 响应数据
    public func uploadImage(
        _ url: String,
        imageData: Data,
        fileName: String = "image.jpg",
        mimeType: String = "image/jpeg",
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        progress: ((UploadProgress) -> Void)? = nil
    ) async throws -> Data {
        let mergedParams = NetworkManager.shared.mergedParameters(parameters)

        let response = await AF.upload(
            multipartFormData: { formData in
                formData.append(imageData, withName: "file", fileName: fileName, mimeType: mimeType)
                for (key, value) in mergedParams {
                    if let data = "\(value)".data(using: .utf8) {
                        formData.append(data, withName: key)
                    }
                }
            },
            to: url,
            headers: headers
        )
        .uploadProgress { p in
            progress?(UploadProgress(
                bytesSent: p.completedUnitCount,
                totalBytes: p.totalUnitCount,
                fraction: p.fractionCompleted
            ))
        }
        .validate()
        .serializingData()
        .response

        switch response.result {
        case .success(let data):
            return data
        case .failure(let error):
            throw NetworkError.networkError(error)
        }
    }

    // MARK: - 上传文件

    /// 上传文件
    /// - Parameters:
    ///   - url: 上传地址
    ///   - fileURL: 本地文件路径
    ///   - parameters: 附加参数
    ///   - headers: 请求头
    ///   - progress: 进度回调
    /// - Returns: 响应数据
    public func uploadFile(
        _ url: String,
        fileURL: URL,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        progress: ((UploadProgress) -> Void)? = nil
    ) async throws -> Data {
        var request = AF.upload(fileURL, to: url, headers: headers)

        if let progressHandler = progress {
            request.uploadProgress { p in
                progressHandler(UploadProgress(
                    bytesSent: p.completedUnitCount,
                    totalBytes: p.totalUnitCount,
                    fraction: p.fractionCompleted
                ))
            }
        }

        let response = await request.validate().serializingData().response

        switch response.result {
        case .success(let data):
            return data
        case .failure(let error):
            throw NetworkError.networkError(error)
        }
    }

    // MARK: - 批量上传

    /// 批量上传图片
    public func uploadImages(
        _ url: String,
        images: [(data: Data, name: String)],
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        progress: ((UploadProgress) -> Void)? = nil
    ) async throws -> Data {
        let mergedParams = NetworkManager.shared.mergedParameters(parameters)

        let response = await AF.upload(
            multipartFormData: { formData in
                for (index, image) in images.enumerated() {
                    formData.append(image.data, withName: "file\(index)", fileName: image.name, mimeType: "image/jpeg")
                }
                for (key, value) in mergedParams {
                    if let data = "\(value)".data(using: .utf8) {
                        formData.append(data, withName: key)
                    }
                }
            },
            to: url,
            headers: headers
        )
        .uploadProgress { p in
            progress?(UploadProgress(
                bytesSent: p.completedUnitCount,
                totalBytes: p.totalUnitCount,
                fraction: p.fractionCompleted
            ))
        }
        .validate()
        .serializingData()
        .response

        switch response.result {
        case .success(let data):
            return data
        case .failure(let error):
            throw NetworkError.networkError(error)
        }
    }
}
