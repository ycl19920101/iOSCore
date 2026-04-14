//
//  GradientButton.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 渐变按钮
public final class GradientButton: UIButton {

    /// 渐变颜色
    public var gradientColors: [UIColor] = [.systemBlue, UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1.0)] {
        didSet { setNeedsLayout() }
    }

    /// 渐变方向起点
    public var startPoint: CGPoint = CGPoint(x: 0, y: 0.5) {
        didSet { gradientLayer.startPoint = startPoint }
    }

    /// 渐变方向终点
    public var endPoint: CGPoint = CGPoint(x: 1, y: 0.5) {
        didSet { gradientLayer.endPoint = endPoint }
    }

    /// 圆角
    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            gradientLayer.cornerRadius = cornerRadius
        }
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = gradientColors.map { $0.cgColor }
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.cornerRadius = cornerRadius
        return layer
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.insertSublayer(gradientLayer, at: 0)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.colors = gradientColors.map { $0.cgColor }
    }

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}
