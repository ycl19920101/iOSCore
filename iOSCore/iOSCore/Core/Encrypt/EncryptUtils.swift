//
//  EncryptUtils.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import CommonCrypto
import CryptoKit
import Foundation

/// 加密算法选择
public enum CryptoAlgorithm {
    case md5
    case sha256
    case sha512
    case hmacSHA256
    case hmacSHA512
}

/// 加密工具
public enum EncryptUtils {

    // MARK: - 摘要

    /// MD5 哈希（CommonCrypto，兼容旧系统）
    public static func md5(_ string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)

        if let data = string.data(using: .utf8) {
            _ = data.withUnsafeBytes { body in
                CC_MD5(body.baseAddress, CC_LONG(data.count), &digest)
            }
        }

        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// MD5 哈希（Data）
    public static func md5(_ data: Data) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)

        _ = data.withUnsafeBytes { body in
            CC_MD5(body.baseAddress, CC_LONG(data.count), &digest)
        }

        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// SHA256 哈希
    public static func sha256(_ string: String) -> String {
        let digest = SHA256.hash(data: Data(string.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// SHA256 哈希（Data）
    public static func sha256(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// SHA512 哈希
    public static func sha512(_ string: String) -> String {
        let digest = SHA512.hash(data: Data(string.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - HMAC

    /// HMAC-SHA256
    public static func hmacSHA256(_ string: String, key: String) -> String {
        let symmetricKey = SymmetricKey(data: Data(key.utf8))
        let hmac = HMAC<SHA256>.authenticationCode(for: Data(string.utf8), using: symmetricKey)
        return hmac.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// HMAC-SHA512
    public static func hmacSHA512(_ string: String, key: String) -> String {
        let symmetricKey = SymmetricKey(data: Data(key.utf8))
        let hmac = HMAC<SHA512>.authenticationCode(for: Data(string.utf8), using: symmetricKey)
        return hmac.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - AES-GCM

    /// AES-GCM 加密
    /// - Parameters:
    ///   - data: 明文数据
    ///   - key: 密钥（必须为 16/24/32 字节）
    /// - Returns: (ciphertext, nonce, tag)
    public static func aesEncrypt(_ data: Data, key: Data) throws -> (ciphertext: Data, nonce: Data, tag: Data) {
        let symmetricKey = SymmetricKey(data: key)
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
        return (
            ciphertext: sealedBox.ciphertext,
            nonce: sealedBox.nonce.withUnsafeBytes { Data(bytes: $0.baseAddress!, count: 12) },
            tag: sealedBox.tag
        )
    }

    /// AES-GCM 解密
    /// - Parameters:
    ///   - ciphertext: 密文
    ///   - key: 密钥
    ///   - nonce: 随机数
    ///   - tag: 认证标签
    /// - Returns: 明文
    public static func aesDecrypt(_ ciphertext: Data, key: Data, nonce: Data, tag: Data) throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce),
                                                ciphertext: ciphertext,
                                                tag: tag)
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }

    /// AES-GCM 加密（字符串便捷方法，返回 Base64 编码的组合数据）
    public static func aesEncrypt(_ string: String, key: String) throws -> String {
        guard let keyData = key.data(using: .utf8), let stringData = string.data(using: .utf8) else {
            return ""
        }
        // 确保 key 为 32 字节（AES-256）
        let finalKey: Data
        if keyData.count < 32 {
            finalKey = keyData + Data(repeating: 0, count: 32 - keyData.count)
        } else {
            finalKey = Data(keyData.prefix(32))
        }

        let symmetricKey = SymmetricKey(data: finalKey)
        let sealedBox = try AES.GCM.seal(stringData, using: symmetricKey)
        // 组合格式: nonce(12) + tag(16) + ciphertext
        let combined = sealedBox.nonce.withUnsafeBytes { Data(bytes: $0.baseAddress!, count: 12) }
            + sealedBox.tag
            + sealedBox.ciphertext
        return combined.base64EncodedString()
    }

    /// AES-GCM 解密（字符串便捷方法）
    public static func aesDecrypt(_ base64String: String, key: String) throws -> String {
        guard let combined = Data(base64Encoded: base64String),
              let keyData = key.data(using: .utf8) else {
            return ""
        }
        let finalKey: Data
        if keyData.count < 32 {
            finalKey = keyData + Data(repeating: 0, count: 32 - keyData.count)
        } else {
            finalKey = Data(keyData.prefix(32))
        }

        guard combined.count > 28 else { return "" }
        let nonce = combined.prefix(12)
        let tag = combined[12..<28]
        let ciphertext = combined[28...]

        let symmetricKey = SymmetricKey(data: finalKey)
        let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce),
                                                ciphertext: ciphertext,
                                                tag: tag)
        let decrypted = try AES.GCM.open(sealedBox, using: symmetricKey)
        return String(data: decrypted, encoding: .utf8) ?? ""
    }

    // MARK: - Base64

    /// Base64 编码
    public static func base64Encode(_ string: String) -> String {
        Data(string.utf8).base64EncodedString()
    }

    /// Base64 解码
    public static func base64Decode(_ string: String) -> String? {
        guard let data = Data(base64Encoded: string) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - 通用接口

    /// 通用哈希方法
    public static func hash(_ string: String, algorithm: CryptoAlgorithm, key: String? = nil) -> String {
        switch algorithm {
        case .md5:
            return md5(string)
        case .sha256:
            return sha256(string)
        case .sha512:
            return sha512(string)
        case .hmacSHA256:
            return hmacSHA256(string, key: key ?? "")
        case .hmacSHA512:
            return hmacSHA512(string, key: key ?? "")
        }
    }

    /// 生成随机密钥（指定字节长度）
    public static func randomKey(length: Int = 32) -> String {
        let key = SymmetricKey(size: SymmetricKeySize(bitCount: length * 8))
        return key.withUnsafeBytes { Data(bytes: $0.baseAddress!, count: length).base64EncodedString() }
    }
}
