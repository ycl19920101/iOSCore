//
//  DeviceInfo.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/10.
//

import CoreTelephony
import Foundation
import Network
import UIKit

#if canImport(AdSupport)
import AdSupport
#endif

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// 设备信息收集
public struct DeviceInfo {

    // MARK: - 系统信息

    /// 系统名称，如 "iOS"
    public static let systemName: String = UIDevice.current.systemName

    /// 系统版本，如 "18.0"
    public static let systemVersion: String = UIDevice.current.systemVersion

    // MARK: - 设备信息

    /// 设备型号，如 "iPhone15,2"
    public static let deviceModel: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }()

    /// 制造商
    public static let manufacturer: String = "Apple"

    // MARK: - 屏幕信息

    /// 屏幕宽度（逻辑像素）
    public static let screenWidth: CGFloat = UIScreen.main.bounds.width

    /// 屏幕高度（逻辑像素）
    public static let screenHeight: CGFloat = UIScreen.main.bounds.height

    /// 屏幕缩放比例
    public static let screenScale: CGFloat = UIScreen.main.scale

    /// 屏幕 DPI
    public static let screenDPI: CGFloat = UIScreen.main.scale * 160.0

    // MARK: - 运营商信息

    /// 运营商名称
    public static let carrierName: String? = {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            return networkInfo.serviceSubscriberCellularProviders?.values
                .compactMap { $0.carrierName }
                .first
        } else {
            return networkInfo.subscriberCellularProvider?.carrierName
        }
    }()

    // MARK: - 网络信息

    /// 当前网络类型："wifi" / "cellular" / "unknown"
    public static var networkType: String {
        let monitor = NWPathMonitor()
        var type = "unknown"
        let semaphore = DispatchSemaphore(value: 0)

        monitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                type = "wifi"
            } else if path.usesInterfaceType(.cellular) {
                type = "cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                type = "wired"
            }
            semaphore.signal()
            monitor.cancel()
        }
        monitor.start(queue: DispatchQueue.global())
        _ = semaphore.wait(timeout: .now() + 2.0)
        return type
    }

    // MARK: - 越狱检测

    /// 是否越狱
    public static let isJailbroken: Bool = {
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }()

    // MARK: - IDFA

    /// IDFA（需用户授权），未授权返回 "0"
    public static var idfa: String {
        #if canImport(AppTrackingTransparency)
        if ATTrackingManager.trackingAuthorizationStatus == .authorized {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        #endif
        return "0"
    }

    // MARK: - YCLUUID

    /// 自有用户标识（UUID 去掉连字符，32位十六进制），持久化存储
    public static var yclUUID: String {
        let key = "com.ioscore.ycluuid"
        if let stored = UserDefaults.standard.string(forKey: key) {
            return stored
        }
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        UserDefaults.standard.set(uuid, forKey: key)
        return uuid
    }
}
