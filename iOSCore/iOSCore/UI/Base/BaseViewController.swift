//
//  BaseViewController.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 基础 ViewController
open class BaseViewController: UIViewController {

    // MARK: - 生命周期

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindEvents()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - 子类重写

    /// 设置 UI 元素
    open func setupUI() {
        view.backgroundColor = .white
    }

    /// 设置约束
    open func setupConstraints() {}

    /// 绑定事件
    open func bindEvents() {}

    // MARK: - Loading

    private var loadingView: UIView?
    private var loadingLabel: UILabel?

    /// 显示 Loading
    public func showLoading(_ message: String = "加载中...") {
        guard loadingView == nil else { return }

        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.frame = view.bounds

        let container = UIView()
        container.backgroundColor = UIColor(white: 0, alpha: 0.7)
        container.layer.cornerRadius = 10
        container.clipsToBounds = true

        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.startAnimating()

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center

        container.addSubview(indicator)
        container.addSubview(label)
        overlay.addSubview(container)
        view.addSubview(overlay)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 120),
            container.heightAnchor.constraint(equalToConstant: 100),

            indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),

            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 10),
        ])

        loadingView = overlay
        loadingLabel = label
    }

    /// 隐藏 Loading
    public func hideLoading() {
        loadingView?.removeFromSuperview()
        loadingView = nil
        loadingLabel = nil
    }

    // MARK: - Empty State

    private var emptyView: UIView?

    /// 显示空状态
    public func showEmpty(_ message: String = "暂无数据") {
        guard emptyView == nil else { return }

        let container = UIView()
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.frame = view.bounds

        let label = UILabel()
        label.text = message
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center

        container.addSubview(label)
        view.addSubview(container)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        emptyView = container
    }

    /// 隐藏空状态
    public func hideEmpty() {
        emptyView?.removeFromSuperview()
        emptyView = nil
    }
}
