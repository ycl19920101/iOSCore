//
//  LimitInputTextField.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 限输入框（支持最大字数限制、小数点位数限制）
public final class LimitInputTextField: UITextField {

    /// 最大字符数（0 不限制）
    public var maxLength: Int = 0

    /// 最大小数点位数（0 不限制）
    public var maxDecimalPlaces: Int = 0

    /// 允许的字符集（nil 不限制）
    public var allowedCharacterSet: CharacterSet?

    /// 字数变化回调
    public var onTextChange: ((String) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    @objc private func textDidChange() {
        guard let text = text else { return }
        var filtered = text

        // 字符集过滤
        if let allowed = allowedCharacterSet {
            filtered = filtered.unicodeScalars.filter { allowed.contains($0) }.map(String.init).joined()
        }

        // 小数位限制
        if maxDecimalPlaces > 0, filtered.contains(".") {
            let parts = filtered.split(separator: ".", maxSplits: 1)
            if parts.count > 1 && parts[1].count > maxDecimalPlaces {
                filtered = String(parts[0]) + "." + String(parts[1].prefix(maxDecimalPlaces))
            }
        }

        // 长度限制
        if maxLength > 0 && filtered.count > maxLength {
            filtered = String(filtered.prefix(maxLength))
        }

        if filtered != text {
            self.text = filtered
        }

        onTextChange?(filtered)
    }
}
