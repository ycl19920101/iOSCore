//
//  DatePickerSheet.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 日期选择器弹窗
public final class DatePickerSheet: UIView {

    public typealias DateSelectedHandler = (Date) -> Void

    /// 选择回调
    public var onDateSelected: DateSelectedHandler?

    /// 最小日期
    public var minimumDate: Date? {
        didSet { datePicker.minimumDate = minimumDate }
    }

    /// 最大日期
    public var maximumDate: Date? {
        didSet { datePicker.maximumDate = maximumDate }
    }

    /// 当前选择日期
    public var selectedDate: Date {
        datePicker.date
    }

    private let datePicker = UIDatePicker()
    private var containerView: UIView!

    public init(mode: UIDatePicker.Mode = .date, locale: Locale = Locale(identifier: "zh_CN")) {
        super.init(frame: .zero)
        setupViews(mode: mode, locale: locale)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews(mode: UIDatePicker.Mode = .dateAndTime, locale: Locale = Locale(identifier: "zh_CN")) {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12

        // 工具栏
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelTapped)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirmTapped)),
        ]

        datePicker.datePickerMode = mode
        datePicker.locale = locale
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        containerView.addSubview(toolbar)
        containerView.addSubview(datePicker)
        addSubview(containerView)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            toolbar.topAnchor.constraint(equalTo: containerView.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),

            datePicker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            datePicker.heightAnchor.constraint(equalToConstant: 216),
        ])
    }

    /// 显示
    public func show(in view: UIView? = nil, initialDate: Date? = nil) {
        let parentView = view ?? UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIView()
        frame = parentView.bounds
        alpha = 0

        if let date = initialDate {
            datePicker.setDate(date, animated: false)
        }

        parentView.addSubview(self)
        layoutIfNeeded()

        let containerHeight = containerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        containerView.transform = CGAffineTransform(translationX: 0, y: containerHeight)

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }

    @objc private func cancelTapped() {
        dismiss()
    }

    @objc private func confirmTapped() {
        onDateSelected?(datePicker.date)
        dismiss()
    }

    private func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
