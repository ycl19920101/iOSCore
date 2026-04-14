//
//  PlaceholderTextView.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 带占位符的 UITextView
public final class PlaceholderTextView: UITextView {

    /// 占位文字
    public var placeholder: String? {
        didSet { placeholderLabel.text = placeholder }
    }

    /// 占位文字颜色
    public var placeholderColor: UIColor = UIColor(white: 0, alpha: 0.25) {
        didSet { placeholderLabel.textColor = placeholderColor }
    }

    /// 占位文字字体
    public var placeholderFont: UIFont? {
        didSet { placeholderLabel.font = placeholderFont ?? font }
    }

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = placeholderColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(placeholderLabel)

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainerInset.left + 4),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -textContainerInset.right - 4),
        ])
    }

    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    public override var text: String! {
        didSet {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }

    public override var font: UIFont? {
        didSet {
            placeholderLabel.font = placeholderFont ?? font
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
