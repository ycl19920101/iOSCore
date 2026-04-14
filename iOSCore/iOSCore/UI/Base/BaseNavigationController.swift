//
//  BaseNavigationController.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 基础导航控制器
open class BaseNavigationController: UINavigationController {

    /// 是否支持全屏返回手势
    public var enableFullScreenGesture: Bool = true

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupFullScreenGesture()
    }

    // MARK: - 全屏返回手势

    private func setupFullScreenGesture() {
        guard enableFullScreenGesture,
              let gesture = interactivePopGestureRecognizer,
              let target = gesture.value(forKey: "target"),
              let action = gesture.value(forKey: "action") as? Selector else { return }

        let panGesture = UIPanGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(panGesture)
        gesture.isEnabled = false
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
