//
//  LogManager.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/1.
//

import Foundation
import SwiftyBeaver

/// 日志级别
public enum LogLevel: Int {
    case verbose
    case debug
    case info
    case warning
    case error
}

/// 日志管理器（基于 SwiftyBeaver）
public final class LogManager {

    public static let shared = LogManager()

    private let log = SwiftyBeaver.self

    private init() {
        let console = ConsoleDestination()
        console.useNSLog = false
        console.minLevel = .verbose

        let file = FileDestination()
        file.logFileAmount = 7
        file.logFileMaxSize = 5 * 1024 * 1024
        file.minLevel = .verbose

        log.addDestination(console)
        log.addDestination(file)
    }

    // MARK: - 日志输出

    public func verbose(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log.verbose(message(), file: file, function: function, line: line)
    }

    public func debug(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log.debug(message(), file: file, function: function, line: line)
    }

    public func info(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log.info(message(), file: file, function: function, line: line)
    }

    public func warning(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log.warning(message(), file: file, function: function, line: line)
    }

    public func error(
        _ message: @autoclosure () -> Any,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log.error(message(), file: file, function: function, line: line)
    }

    // MARK: - 配置

    /// 设置最低日志级别
    public func setMinLogLevel(_ level: LogLevel) {
        let sbLevel: SwiftyBeaver.Level = SwiftyBeaver.Level(rawValue: level.rawValue) ?? .verbose
        for dest in log.destinations {
            dest.minLevel = sbLevel
        }
    }

    /// 获取日志文件路径
    public func logFilePath() -> String? {
        for dest in log.destinations {
            if let fileDest = dest as? FileDestination {
                return fileDest.logFileURL?.path
            }
        }
        return nil
    }

    /// 清除日志文件
    public func clearLogFiles() {
        for dest in log.destinations {
            if let fileDest = dest as? FileDestination {
                _ = fileDest.deleteLogFile()
            }
        }
    }
}
