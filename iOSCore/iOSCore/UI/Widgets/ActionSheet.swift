//
//  ActionSheet.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 自定义 ActionSheet
public final class ActionSheet: UIView {

    public struct Action {
        public let title: String
        public let style: Style
        public let handler: (() -> Void)?

        public enum Style {
            case `default`
            case destructive
            case cancel
        }

        public init(title: String, style: Style = .default, handler: (() -> Void)? = nil) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }

    // MARK: - Properties

    private var actions: [Action] = []
    private var containerView: UIView!
    private var tableView: UITableView!

    private static let actionHeight: CGFloat = 50
    private static let headerHeight: CGFloat = 44
    private static let cornerRadius: CGFloat = 12

    // MARK: - Init

    public init(title: String? = nil, message: String? = nil) {
        super.init(frame: .zero)
        setupViews(title: title, message: message)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews(title: String? = nil, message: String? = nil) {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        containerView = UIView()
        containerView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        containerView.layer.cornerRadius = ActionSheet.cornerRadius
        containerView.clipsToBounds = true

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        addSubview(containerView)
        containerView.addSubview(tableView)
    }

    // MARK: - Public

    /// 添加操作
    public func addAction(_ action: Action) {
        actions.append(action)
    }

    /// 显示
    public func show(in view: UIView? = nil) {
        let parentView = view ?? UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIView()
        frame = parentView.bounds
        alpha = 0

        let totalHeight = Self.headerHeight + CGFloat(actions.count) * Self.actionHeight + 20
        containerView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: totalHeight)
        tableView.frame = CGRect(x: 0, y: Self.headerHeight, width: bounds.width, height: CGFloat(actions.count) * Self.actionHeight)

        parentView.addSubview(self)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.containerView.frame.origin.y = self.bounds.height - totalHeight - ViewUtils.safeAreaBottom
        }
    }

    /// 隐藏
    public func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.containerView.frame.origin.y = self.bounds.height
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ActionSheet: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        actions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let action = actions[indexPath.row]

        cell.textLabel?.text = action.title
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none

        switch action.style {
        case .default:
            cell.textLabel?.textColor = .black
        case .destructive:
            cell.textLabel?.textColor = .red
        case .cancel:
            cell.textLabel?.textColor = .systemBlue
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ActionSheet.actionHeight
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action.handler?()
        }
    }
}
