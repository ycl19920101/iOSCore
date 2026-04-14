//
//  UIKitExtensions.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

// MARK: - UIView Extensions

public extension UIView {

    /// 圆角
    var yclCornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    /// 边框宽度
    var yclBorderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    /// 边框颜色
    var yclBorderColor: UIColor? {
        get { layer.borderColor.map { UIColor(cgColor: $0) } }
        set { layer.borderColor = newValue?.cgColor }
    }

    /// 阴影颜色
    var yclShadowColor: UIColor? {
        get { layer.shadowColor.map { UIColor(cgColor: $0) } }
        set { layer.shadowColor = newValue?.cgColor }
    }

    /// 通过 NSCoder / Storyboard 初始化时自动加载圆角
    @IBInspectable var cornerRadiusIB: CGFloat {
        get { yclCornerRadius }
        set { yclCornerRadius = newValue }
    }

    /// 添加子视图并关闭 translatesAutoresizingMaskIntoConstraints
    func addSubviewAutoLayout(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }

    /// 添加多个子视图
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }

    /// 填充到父视图
    func fillSuperview(inset: UIEdgeInsets = .zero) {
        guard let sv = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: sv.topAnchor, constant: inset.top),
            leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: inset.left),
            trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: -inset.right),
            bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: -inset.bottom),
        ])
    }

    /// 水平居中 + 垂直居中
    func centerInSuperview() {
        guard let sv = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: sv.centerXAnchor),
            centerYAnchor.constraint(equalTo: sv.centerYAnchor),
        ])
    }
}

// MARK: - UIColor Extensions

public extension UIColor {

    /// 十六进制颜色
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /// 0xRRGGBB
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - UIImage Extensions

public extension UIImage {

    /// 从颜色创建图片
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    /// 压缩到指定最大字节
    func compress(to maxBytes: Int) -> Data? {
        let options: [NSString: Any] = [:]
        var compression: CGFloat = 1.0
        var data = jpegData(compressionQuality: compression)

        while let d = data, d.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            data = jpegData(compressionQuality: compression)
        }
        return data
    }

    /// 等比缩放
    func scaled(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - UIViewController Extensions

public extension UIViewController {

    /// 添加子 ViewController
    func addChildController(_ child: UIViewController, to containerView: UIView? = nil) {
        addChild(child)
        (containerView ?? self.view)?.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// 移除子 ViewController
    func removeChild(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
