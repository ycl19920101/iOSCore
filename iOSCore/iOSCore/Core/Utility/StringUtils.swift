//
//  StringUtils.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation
import UIKit

/// 字符串工具
public enum StringUtils {

    // MARK: - 判断

    /// 是否为空或纯空白字符
    public static func isBlank(_ string: String?) -> Bool {
        guard let string = string else { return true }
        return string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 是否是有效邮箱
    public static func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return match(email, pattern: pattern)
    }

    /// 是否是有效手机号（中国大陆）
    public static func isValidPhone(_ phone: String) -> Bool {
        let pattern = "^1[3-9]\\d{9}$"
        return match(phone, pattern: pattern)
    }

    /// 是否是纯数字
    public static func isNumeric(_ string: String) -> Bool {
        let pattern = "^\\d+$"
        return match(string, pattern: pattern)
    }

    /// 是否只包含字母
    public static func isAlpha(_ string: String) -> Bool {
        let pattern = "^[a-zA-Z]+$"
        return match(string, pattern: pattern)
    }

    /// 是否是有效 URL
    public static func isValidURL(_ string: String) -> Bool {
        URL(string: string) != nil
    }

    // MARK: - 正则

    /// 正则匹配
    public static func match(_ string: String, pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return false }
        let range = NSRange(string.startIndex..., in: string)
        return regex.firstMatch(in: string, options: [], range: range) != nil
    }

    /// 正则提取所有匹配
    public static func matches(_ string: String, pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let range = NSRange(string.startIndex..., in: string)
        let results = regex.matches(in: string, options: [], range: range)
        return results.compactMap { result in
            guard let range = Range(result.range, in: string) else { return nil }
            return String(string[range])
        }
    }

    /// 正则替换
    public static func replace(_ string: String, pattern: String, replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return string }
        let range = NSRange(string.startIndex..., in: string)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replacement)
    }

    // MARK: - 截取

    /// 截取子字符串（安全范围）
    public static func substring(_ string: String, from: Int, length: Int? = nil) -> String {
        let start = string.index(string.startIndex, offsetBy: min(from, string.count))
        if let length = length {
            let end = string.index(start, offsetBy: min(length, string.count - from))
            return String(string[start..<end])
        }
        return String(string[start...])
    }

    // MARK: - 转换

    /// URL 编码
    public static func urlEncode(_ string: String) -> String? {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    /// URL 解码
    public static func urlDecode(_ string: String) -> String? {
        string.removingPercentEncoding
    }

    /// 去除 HTML 标签
    public static func stripHTML(_ string: String) -> String {
        replace(string, pattern: "<[^>]+>", replacement: "")
    }

    /// 首字母大写
    public static func capitalizeFirst(_ string: String) -> String {
        guard let first = string.first else { return string }
        return String(first).uppercased() + String(string.dropFirst())
    }

    /// 计算文字宽度/高度
    public static func size(
        _ string: String,
        font: UIFont,
        constrainedWidth: CGFloat = .greatestFiniteMagnitude,
        constrainedHeight: CGFloat = .greatestFiniteMagnitude
    ) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let rect = (string as NSString).boundingRect(
            with: CGSize(width: constrainedWidth, height: constrainedHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }

    /// 随机字符串
    public static func random(length: Int = 8) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
}
