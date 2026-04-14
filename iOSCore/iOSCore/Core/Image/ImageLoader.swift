//
//  ImageLoader.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/1.
//

import UIKit
import Kingfisher

/// 图片加载错误
public enum ImageLoadError: Error {
    case invalidURL
    case downloadFailed(Error)
    case processingFailed
}

/// 图片加载管理器（基于 Kingfisher）
public final class ImageLoader {

    public static let shared = ImageLoader()

    private init() {}

    // MARK: - UIImageView 加载

    /// 加载网络图片到 UIImageView
    @MainActor
    public func load(
        _ imageView: UIImageView,
        url: String,
        placeholder: UIImage? = nil
    ) {
        guard let kfURL = URL(string: url) else { return }
        imageView.kf.setImage(with: kfURL, placeholder: placeholder)
    }

    /// 加载网络图片到 UIImageView（带完成回调）
    @MainActor
    public func load(
        _ imageView: UIImageView,
        url: String,
        placeholder: UIImage? = nil,
        completionHandler: @escaping (Result<UIImage, ImageLoadError>) -> Void
    ) {
        guard let kfURL = URL(string: url) else {
            completionHandler(.failure(.invalidURL))
            return
        }
        imageView.kf.setImage(
            with: kfURL,
            placeholder: placeholder
        ) { result in
            switch result {
            case .success(let imageResult):
                completionHandler(.success(imageResult.image))
            case .failure(let error):
                completionHandler(.failure(.downloadFailed(error)))
            }
        }
    }

    // MARK: - Async/Await

    /// 异步获取图片
    public func fetchImage(url: String) async throws -> UIImage {
        guard let kfURL = URL(string: url) else {
            throw ImageLoadError.invalidURL
        }
        do {
            let result = try await KingfisherManager.shared.retrieveImage(with: kfURL)
            return result.image
        } catch let error as ImageLoadError {
            throw error
        } catch {
            throw ImageLoadError.downloadFailed(error)
        }
    }

    // MARK: - 取消加载

    /// 取消 UIImageView 的图片加载
    @MainActor
    public func cancel(_ imageView: UIImageView) {
        imageView.kf.cancelDownloadTask()
    }

    // MARK: - 缓存管理

    /// 清除内存缓存
    public func clearMemoryCache() {
        ImageCache.default.clearMemoryCache()
    }

    /// 清除磁盘缓存
    public func clearDiskCache() async {
        await ImageCache.default.clearDiskCache()
    }

    /// 获取磁盘缓存大小
    public func diskCacheSize() async -> UInt {
        (try? await ImageCache.default.diskStorageSize) ?? 0
    }
}
