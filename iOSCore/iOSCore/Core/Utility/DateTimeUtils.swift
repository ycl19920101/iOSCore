//
//  DateTimeUtils.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation

/// 日期时间工具
public enum DateTimeUtils {

    // MARK: - 格式化

    /// 日期格式化为字符串
    public static func format(_ date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    /// 字符串转日期
    public static func parse(_ string: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string)
    }

    /// ISO8601 格式字符串转日期
    public static func parseISO8601(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }

    /// 日期转 ISO8601 字符串
    public static func toISO8601(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    // MARK: - 时间戳

    /// 当前时间戳（秒）
    public static func timestamp() -> Int64 {
        Int64(Date().timeIntervalSince1970)
    }

    /// 当前时间戳（毫秒）
    public static func timestampMillis() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }

    /// 时间戳转日期
    public static func date(fromTimestamp timestamp: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    /// 时间戳（毫秒）转日期
    public static func date(fromTimestampMillis millis: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(millis) / 1000.0)
    }

    // MARK: - 相对时间

    /// 友好的时间描述（如"刚刚"、"3分钟前"、"昨天"）
    public static func relativeString(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let seconds = Int(interval)

        if seconds < 60 {
            return "刚刚"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)分钟前"
        }

        let hours = minutes / 60
        if hours < 24 {
            return "\(hours)小时前"
        }

        let days = hours / 24
        if days < 2 {
            return "昨天"
        }
        if days < 30 {
            return "\(days)天前"
        }

        let months = days / 30
        if months < 12 {
            return "\(months)个月前"
        }

        let years = months / 12
        return "\(years)年前"
    }

    // MARK: - 日期计算

    /// 获取日期的起始时间（00:00:00）
    public static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    /// 获取日期的结束时间（23:59:59）
    public static func endOfDay(_ date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay(date)) ?? date
    }

    /// 添加天数
    public static func addDays(_ days: Int, to date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
    }

    /// 两个日期之间的天数差
    public static func daysBetween(_ date1: Date, _ date2: Date) -> Int {
        let start1 = startOfDay(date1)
        let start2 = startOfDay(date2)
        return Calendar.current.dateComponents([.day], from: start1, to: start2).day ?? 0
    }

    /// 是否是今天
    public static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    /// 是否是昨天
    public static func isYesterday(_ date: Date) -> Bool {
        Calendar.current.isDateInYesterday(date)
    }
}
