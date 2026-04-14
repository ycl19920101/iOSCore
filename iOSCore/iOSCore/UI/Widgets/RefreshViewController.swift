//
//  RefreshViewController.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 带下拉刷新和上拉加载的 ViewController
open class RefreshViewController: BaseViewController {

    /// ScrollView（子类赋值）
    public var scrollView: UIScrollView? {
        didSet {
            setupRefresh()
        }
    }

    /// 是否正在刷新
    public private(set) var isRefreshing = false

    /// 是否正在加载更多
    public private(set) var isLoadingMore = false

    /// 是否还有更多数据
    public var hasMore: Bool = true

    /// 下拉刷新回调
    public var onRefresh: (() -> Void)?

    /// 上拉加载回调
    public var onLoadMore: (() -> Void)?

    /// 是否启用下拉刷新
    public var pullToRefreshEnabled: Bool = true {
        didSet {
            refreshControl = pullToRefreshEnabled ? UIRefreshControl() : nil
        }
    }

    private var refreshControl: UIRefreshControl?

    open override func setupUI() {
        super.setupUI()
    }

    private func setupRefresh() {
        guard let scrollView = scrollView else { return }
        scrollView.alwaysBounceVertical = true

        if pullToRefreshEnabled {
            let rc = UIRefreshControl()
            rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
            scrollView.addSubview(rc)
            refreshControl = rc
        }
    }

    @objc private func handleRefresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        onRefresh?()
    }

    open func onScrollViewDidScroll(_ scrollView: UIScrollView) {

        guard !isLoadingMore && !isRefreshing && hasMore else { return }
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.bounds.height
        let offsetY = scrollView.contentOffset.y

        if offsetY > contentHeight - visibleHeight - 100 {
            isLoadingMore = true
            onLoadMore?()
        }
    }

    /// 结束刷新
    public func endRefresh() {
        isRefreshing = false
        refreshControl?.endRefreshing()
    }

    /// 结束加载更多
    public func endLoadingMore() {
        isLoadingMore = false
    }

    /// 结束所有加载状态
    public func endAllLoading() {
        endRefresh()
        endLoadingMore()
    }
}
