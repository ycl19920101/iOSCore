//
//  SmartTimer.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import Foundation
import QuartzCore

/// 智能定时器（基于 DispatchSourceTimer）
public final class SmartTimer {

    /// 定时器状态
    public private(set) var isRunning = false

    private var timer: DispatchSourceTimer?
    private let interval: TimeInterval
    private let handler: () -> Bool // return false to stop
    private let queue: DispatchQueue

    /// 创建定时器
    /// - Parameters:
    ///   - interval: 间隔（秒）
    ///   - queue: 执行队列，默认 main
    ///   - handler: 执行闭包，返回 false 停止定时器
    public init(interval: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Bool) {
        self.interval = interval
        self.queue = queue
        self.handler = handler
    }

    /// 启动定时器
    public func start() {
        guard !isRunning else { return }
        isRunning = true

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + interval, repeating: interval, leeway: .milliseconds(50))
        timer.setEventHandler { [weak self] in
            guard let self = self, self.isRunning else { return }
            if !self.handler() {
                self.stop()
            }
        }
        timer.resume()
        self.timer = timer
    }

    /// 停止定时器
    public func stop() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    deinit {
        stop()
    }

    // MARK: - 便捷方法

    /// 创建一次性延迟执行
    @discardableResult
    public static func once(after delay: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Void) -> DispatchQueue {
        let timerQueue = DispatchQueue(label: "com.ioscore.smarttimer.once")
        timerQueue.asyncAfter(deadline: .now() + delay) {
            queue.async { handler() }
        }
        return timerQueue
    }

    /// 创建重复定时器
    @discardableResult
    public static func repeating(
        interval: TimeInterval,
        queue: DispatchQueue = .main,
        handler: @escaping () -> Bool
    ) -> SmartTimer {
        let timer = SmartTimer(interval: interval, queue: queue, handler: handler)
        timer.start()
        return timer
    }
}

/// 防抖/节流工具
public enum ThrottleUtils {

    /// 防抖：在指定时间内只执行最后一次
    public static func debounce(
        interval: TimeInterval,
        action: @escaping () -> Void
    ) -> () -> Void {
        var workItem: DispatchWorkItem?
        return {
            workItem?.cancel()
            let item = DispatchWorkItem { action() }
            workItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: item)
        }
    }

    /// 节流：在指定时间内只执行第一次
    public static func throttle(
        interval: TimeInterval,
        action: @escaping () -> Void
    ) -> () -> Void {
        var lastFire: TimeInterval = 0
        return {
            let now = CACurrentMediaTime()
            guard now - lastFire >= interval else { return }
            lastFire = now
            action()
        }
    }
}
