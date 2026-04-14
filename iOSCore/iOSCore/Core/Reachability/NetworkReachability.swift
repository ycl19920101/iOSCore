//
//  NetworkReachability.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Alamofire
import Combine
import Foundation

/// 网络状态
public enum NetworkStatus {
    case unknown
    case notReachable
    case wifi
    case cellular

    var isReachable: Bool {
        switch self {
        case .wifi, .cellular: return true
        default: return false
        }
    }

    var description: String {
        switch self {
        case .unknown: return "unknown"
        case .notReachable: return "notReachable"
        case .wifi: return "wifi"
        case .cellular: return "cellular"
        }
    }
}

/// 网络可达性监控（基于 Alamofire NetworkReachabilityManager + Combine）
public final class NetworkReachability {

    public static let shared = NetworkReachability()

    /// 当前网络状态
    public private(set) var currentStatus: NetworkStatus = .unknown

    /// 状态变化 Publisher
    public let statusPublisher = PassthroughSubject<NetworkStatus, Never>()

    private let manager: NetworkReachabilityManager?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        manager = NetworkReachabilityManager()
        monitor()
    }

    /// 指定 host 的可达性监控
    public init(host: String) {
        manager = NetworkReachabilityManager(host: host)
        monitor()
    }

    private func monitor() {
        guard let manager = manager else { return }

        manager.startListening { [weak self] status in
            let networkStatus: NetworkStatus
            switch status {
            case .notReachable:
                networkStatus = .notReachable
            case .unknown:
                networkStatus = .unknown
            case .reachable(let type):
                switch type {
                case .ethernetOrWiFi:
                    networkStatus = .wifi
                case .cellular:
                    networkStatus = .cellular
                }
            }
            self?.currentStatus = networkStatus
            self?.statusPublisher.send(networkStatus)
        }
    }

    /// 当前是否可达
    public var isReachable: Bool {
        manager?.isReachable ?? false
    }

    /// 是否通过 WiFi 连接
    public var isReachableOnWiFi: Bool {
        manager?.isReachableOnEthernetOrWiFi ?? false
    }

    /// 是否通过蜂窝连接
    public var isReachableOnCellular: Bool {
        manager?.isReachableOnCellular ?? false
    }

    deinit {
        manager?.stopListening()
    }
}
