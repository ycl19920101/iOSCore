//
//  StorageManager.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/1.
//

import Foundation
import KeychainAccess

/// 存储错误
public enum StorageError: Error {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileNotFound
    case writeFailed(Error)
    case readFailed(Error)
    case deleteFailed(Error)
}

/// 沙盒目录
public enum SandboxDirectory {
    case documents
    case caches
    case tmp

    var url: URL {
        switch self {
        case .documents:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        case .caches:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        case .tmp:
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
}

/// 数据存储管理器（Keychain + UserDefaults + 文件存储）
public final class StorageManager {

    public static let shared = StorageManager()

    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.iOSCore.default")
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    // MARK: - Keychain（Codable）

    /// 保存数据到 Keychain
    public func saveToKeychain<T: Codable>(_ value: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(value)
            try keychain.set(data, key: key)
        } catch {
            throw StorageError.encodingFailed(error)
        }
    }

    /// 从 Keychain 加载数据
    public func loadFromKeychain<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = try keychain.getData(key) else { return nil }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw StorageError.decodingFailed(error)
        }
    }

    /// 从 Keychain 删除数据
    public func removeFromKeychain(forKey key: String) throws {
        try keychain.remove(key)
    }

    // MARK: - UserDefaults（Codable）

    /// 保存数据到 UserDefaults
    public func saveToDefaults<T: Codable>(_ value: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            throw StorageError.encodingFailed(error)
        }
    }

    /// 从 UserDefaults 加载数据
    public func loadFromDefaults<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    /// 从 UserDefaults 删除数据
    public func removeFromDefaults(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - 文件存储

    /// 写入文件
    public func writeToFile<T: Codable>(_ value: T, fileName: String, directory: SandboxDirectory) throws {
        do {
            let data = try encoder.encode(value)
            let fileURL = directory.url.appendingPathComponent(fileName)
            try data.write(to: fileURL, options: .atomic)
        } catch let error as StorageError {
            throw error
        } catch {
            throw StorageError.writeFailed(error)
        }
    }

    /// 读取文件
    public func readFromFile<T: Codable>(_ type: T.Type, fileName: String, directory: SandboxDirectory) throws -> T? {
        let fileURL = directory.url.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(type, from: data)
        } catch let error as DecodingError {
            throw StorageError.decodingFailed(error)
        } catch {
            throw StorageError.readFailed(error)
        }
    }

    /// 删除文件
    public func deleteFile(fileName: String, directory: SandboxDirectory) throws {
        let fileURL = directory.url.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            throw StorageError.deleteFailed(error)
        }
    }

    /// 文件是否存在
    public func fileExists(fileName: String, directory: SandboxDirectory) -> Bool {
        let fileURL = directory.url.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}
