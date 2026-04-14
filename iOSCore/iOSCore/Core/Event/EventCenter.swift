//
//  EventCenter.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Combine
import Foundation

/// 类型安全的事件总线（基于 Combine）
public final class EventCenter {

    public static let shared = EventCenter()

    private var subjects: [String: Any] = [:]
    private let lock = NSLock()

    private init() {}

    // MARK: - 发送事件

    /// 发送事件
    public func send<T>(_ event: T) {
        let key = eventKey(T.self)
        lock.lock()
        let subject = subjects[key] as? PassthroughSubject<T, Never>
        lock.unlock()
        subject?.send(event)
    }

    // MARK: - 订阅事件

    /// 订阅事件类型
    /// - Parameters:
    ///   - type: 事件类型
    ///   - queue: 接收队列，默认 main
    ///   - handler: 处理闭包
    /// - Returns: AnyCancellable
    @discardableResult
    public func on<T>(
        _ type: T.Type,
        queue: DispatchQueue = .main,
        handler: @escaping (T) -> Void
    ) -> AnyCancellable {
        let key = eventKey(T.self)
        lock.lock()
        if subjects[key] == nil {
            subjects[key] = PassthroughSubject<T, Never>()
        }
        let subject = subjects[key] as! PassthroughSubject<T, Never>
        lock.unlock()

        return subject
            .receive(on: queue)
            .sink { handler($0) }
    }

    // MARK: - Publisher

    /// 获取事件类型的 Publisher
    public func publisher<T>(for type: T.Type) -> AnyPublisher<T, Never> {
        let key = eventKey(T.self)
        lock.lock()
        if subjects[key] == nil {
            subjects[key] = PassthroughSubject<T, Never>()
        }
        let subject = subjects[key] as! PassthroughSubject<T, Never>
        lock.unlock()
        return subject.eraseToAnyPublisher()
    }

    // MARK: - 移除

    /// 移除事件类型的所有订阅
    public func remove<T>(_ type: T.Type) {
        let key = eventKey(T.self)
        lock.lock()
        subjects.removeValue(forKey: key)
        lock.unlock()
    }

    /// 移除所有订阅
    public func removeAll() {
        lock.lock()
        subjects.removeAll()
        lock.unlock()
    }

    // MARK: - Private

    private func eventKey<T>(_ type: T.Type) -> String {
        String(describing: type)
    }
}
