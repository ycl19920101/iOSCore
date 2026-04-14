//
//  FileUtils.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation

/// 文件工具
public enum FileUtils {

    private static let fileManager = FileManager.default

    // MARK: - 沙盒路径

    /// Documents 目录
    public static var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Caches 目录
    public static var cachesDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    /// Temp 目录
    public static var tempDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
    }

    /// Library 目录
    public static var libraryDirectory: URL {
        fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    }

    /// Bundle 目录
    public static var bundleDirectory: URL {
        Bundle.main.bundleURL
    }

    // MARK: - 文件操作

    /// 文件是否存在
    public static func exists(at path: String) -> Bool {
        fileManager.fileExists(atPath: path)
    }

    /// 文件是否存在（URL）
    public static func exists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    /// 创建目录
    @discardableResult
    public static func createDirectory(at url: URL) -> Bool {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }

    /// 创建目录（路径）
    @discardableResult
    public static func createDirectory(at path: String) -> Bool {
        createDirectory(at: URL(fileURLWithPath: path))
    }

    /// 删除文件或目录
    @discardableResult
    public static func remove(at url: URL) -> Bool {
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }

    /// 删除文件或目录（路径）
    @discardableResult
    public static func remove(at path: String) -> Bool {
        remove(at: URL(fileURLWithPath: path))
    }

    /// 复制文件
    @discardableResult
    public static func copy(from source: URL, to destination: URL) -> Bool {
        do {
            try fileManager.copyItem(at: source, to: destination)
            return true
        } catch {
            return false
        }
    }

    /// 移动文件
    @discardableResult
    public static func move(from source: URL, to destination: URL) -> Bool {
        do {
            try fileManager.moveItem(at: source, to: destination)
            return true
        } catch {
            return false
        }
    }

    /// 写入数据到文件
    @discardableResult
    public static func write(_ data: Data, to url: URL, atomic: Bool = true) -> Bool {
        do {
            let directory = url.deletingLastPathComponent()
            if !exists(at: directory) {
                createDirectory(at: directory)
            }
            try data.write(to: url, options: atomic ? .atomic : [])
            return true
        } catch {
            return false
        }
    }

    /// 写入字符串到文件
    @discardableResult
    public static func write(_ string: String, to url: URL, encoding: String.Encoding = .utf8, atomic: Bool = true) -> Bool {
        guard let data = string.data(using: encoding) else { return false }
        return write(data, to: url, atomic: atomic)
    }

    /// 读取文件数据
    public static func readData(at url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    /// 读取文件为字符串
    public static func readString(at url: URL, encoding: String.Encoding = .utf8) -> String? {
        guard let data = readData(at: url) else { return nil }
        return String(data: data, encoding: encoding)
    }

    // MARK: - 文件信息

    /// 文件大小（字节）
    public static func fileSize(at url: URL) -> UInt64 {
        guard let attrs = try? fileManager.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? UInt64 else {
            return 0
        }
        return size
    }

    /// 目录大小（递归计算所有文件）
    public static func directorySize(at url: URL) -> UInt64 {
        guard let enumerator = fileManager.enumerator(at: url,
                                                       includingPropertiesForKeys: [.fileSizeKey],
                                                       options: [.skipsHiddenFiles]) else {
            return 0
        }
        var totalSize: UInt64 = 0
        for case let fileURL as URL in enumerator {
            if let attrs = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = attrs.fileSize {
                totalSize += UInt64(fileSize)
            }
        }
        return totalSize
    }

    /// 格式化文件大小
    public static func formatSize(_ bytes: UInt64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0
        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }
        return String(format: "%.1f %@", value, units[unitIndex])
    }

    /// 列出目录内容
    public static func contentsOfDirectory(at url: URL) -> [URL] {
        (try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
    }

    // MARK: - 清理

    /// 清空 Caches 目录
    public static func clearCaches() {
        let contents = contentsOfDirectory(at: cachesDirectory)
        for url in contents {
            remove(at: url)
        }
    }

    /// 清空 Temp 目录
    public static func clearTemp() {
        let contents = contentsOfDirectory(at: tempDirectory)
        for url in contents {
            remove(at: url)
        }
    }

    /// 获取 App 总磁盘占用
    public static func totalDiskUsage() -> String {
        let size = directorySize(at: documentsDirectory) + directorySize(at: cachesDirectory) + directorySize(at: libraryDirectory)
        return formatSize(size)
    }
}
