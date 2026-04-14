//
//  ViewUtils.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/13.
//

import UIKit

/// 视图工具
public enum ViewUtils {

    // MARK: - 屏幕信息

    /// 屏幕宽度
    public static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    /// 屏幕高度
    public static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    /// 状态栏高度
    @available(iOS 13.0, *)
    public static var statusBarHeight: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets.top ?? 0
    }

    /// 导航栏高度
    public static var navigationBarHeight: CGFloat {
        44.0
    }

    /// TabBar 高度
    @available(iOS 13.0, *)
    public static var tabBarHeight: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let bottomInset = scene?.windows.first?.safeAreaInsets.bottom ?? 0
        return 49.0 + bottomInset
    }

    /// 安全区域底部 inset
    @available(iOS 13.0, *)
    public static var safeAreaBottom: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets.bottom ?? 0
    }

    /// 顶部安全区域高度（状态栏 + 导航栏）
    @available(iOS 13.0, *)
    public static var topSafeArea: CGFloat {
        statusBarHeight + navigationBarHeight
    }

    // MARK: - 尺寸适配

    /// 基于 iPhone 6 (375pt) 的等比缩放
    public static func scale(_ value: CGFloat) -> CGFloat {
        value * screenWidth / 375.0
    }

    // MARK: - View 快捷操作

    /// 获取当前最顶层的 ViewController
    @available(iOS 13.0, *)
    public static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootVC = scene?.windows.first?.rootViewController else { return nil }
        return topViewController(from: rootVC)
    }

    private static func topViewController(from vc: UIViewController) -> UIViewController? {
        if let presented = vc.presentedViewController {
            return topViewController(from: presented)
        }
        if let nav = vc as? UINavigationController, let visible = nav.visibleViewController {
            return topViewController(from: visible)
        }
        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(from: selected)
        }
        return vc
    }

    /// 给视图添加圆角
    public static func addRoundedCorners(_ view: UIView, corners: UIRectCorner, radius: CGSize) {
        let path = UIBezierPath(roundedRect: view.bounds,
                                 byRoundingCorners: corners,
                                 cornerRadii: radius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }

    /// 给视图添加阴影
    public static func addShadow(_ view: UIView,
                                  color: UIColor = .black,
                                  opacity: Float = 0.2,
                                  offset: CGSize = CGSize(width: 0, height: 2),
                                  radius: CGFloat = 4) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.masksToBounds = false
    }

    /// 渐变色视图
    @discardableResult
    public static func applyGradient(_ view: UIView,
                                      colors: [UIColor],
                                      startPoint: CGPoint = CGPoint(x: 0, y: 0),
                                      endPoint: CGPoint = CGPoint(x: 1, y: 1)) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        return gradient
    }

    /// 截图
    public static func screenshot(of view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
