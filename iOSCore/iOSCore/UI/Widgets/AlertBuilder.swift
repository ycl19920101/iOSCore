//
//  AlertBuilder.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// Alert 构建器（链式调用）
public final class AlertBuilder {

    private var title: String?
    private var message: String?
    private var preferredStyle: UIAlertController.Style = .alert
    private var actions: [UIAlertAction] = []
    private weak var presenter: UIViewController?

    public init() {}

    public func title(_ title: String) -> Self {
        self.title = title
        return self
    }

    public func message(_ message: String) -> Self {
        self.message = message
        return self
    }

    public func style(_ style: UIAlertController.Style) -> Self {
        self.preferredStyle = style
        return self
    }

    public func presenter(_ vc: UIViewController) -> Self {
        self.presenter = vc
        return self
    }

    public func action(_ title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) -> Self {
        actions.append(UIAlertAction(title: title, style: style) { _ in handler?() })
        return self
    }

    public func confirm(_ title: String = "确定", handler: (() -> Void)? = nil) -> Self {
        return action(title, style: .default, handler: handler)
    }

    public func cancel(_ title: String = "取消", handler: (() -> Void)? = nil) -> Self {
        return action(title, style: .cancel, handler: handler)
    }

    public func destructive(_ title: String, handler: (() -> Void)? = nil) -> Self {
        return action(title, style: .destructive, handler: handler)
    }

    /// 构建 UIAlertController
    public func build() -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for action in actions {
            alert.addAction(action)
        }
        return alert
    }

    /// 构建并显示
    @discardableResult
    public func show() -> UIAlertController {
        let alert = build()
        let presenter = self.presenter ?? ViewUtils.topViewController()
        presenter?.present(alert, animated: true)
        return alert
    }
}
