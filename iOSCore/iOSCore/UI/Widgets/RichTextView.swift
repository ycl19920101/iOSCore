//
//  RichTextView.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 富文本渲染视图
public final class RichTextView: UIView {

    /// 内容边距
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
        didSet { setNeedsLayout() }
    }

    /// 链接点击回调
    public var onLinkTapped: ((URL) -> Void)?

    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isSelectable = true
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
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
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: contentInset.top),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInset.left),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInset.right),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInset.bottom),
        ])
    }

    /// 设置 HTML 内容
    public func setHTML(_ html: String, fontSize: CGFloat = 15, textColor: UIColor = .black) {
        let styledHTML = """
        <style>
            body { font-size: \(fontSize)px; color: \(hexString(textColor)); font-family: -apple-system; }
            img { max-width: 100%; height: auto; }
            a { color: #007AFF; text-decoration: none; }
        </style>
        \(html)
        """
        if let data = styledHTML.data(using: .unicode),
           let attributed = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            textView.attributedText = attributed
        }
    }

    /// 设置富文本
    public func setAttributedText(_ attributed: NSAttributedString) {
        textView.attributedText = attributed
    }

    /// 设置纯文本
    public func setText(_ text: String, fontSize: CGFloat = 15, textColor: UIColor = .black) {
        textView.font = .systemFont(ofSize: fontSize)
        textView.textColor = textColor
        textView.text = text
    }

    private func hexString(_ color: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - UITextViewDelegate

extension RichTextView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        onLinkTapped?(URL)
        return onLinkTapped == nil
    }
}
