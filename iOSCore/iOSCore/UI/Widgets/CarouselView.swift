//
//  CarouselView.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit

/// 无限轮播视图
public final class CarouselView: UIView {

    public struct Item {
        public let imageURL: String?
        public let image: UIImage?
        public let title: String?
        public let userInfo: [AnyHashable: Any]?

        public init(imageURL: String? = nil, image: UIImage? = nil, title: String? = nil, userInfo: [AnyHashable: Any]? = nil) {
            self.imageURL = imageURL
            self.image = image
            self.title = title
            self.userInfo = userInfo
        }
    }

    // MARK: - Public Properties

    /// 点击回调
    public var onItemClick: ((Item, Int) -> Void)?

    /// 自动滚动间隔（秒），0 不自动滚动
    public var autoScrollInterval: TimeInterval = 3.0 {
        didSet { setupTimer() }
    }

    /// 当前页
    public private(set) var currentPage: Int = 0

    /// 数据源
    public var items: [Item] = [] {
        didSet { reloadData() }
    }

    // MARK: - Private

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.delegate = self
        sv.bounces = false
        return sv
    }()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pc.hidesForSinglePage = true
        return pc
    }()

    private var imageViews: [UIImageView] = []
    private var timer: Timer?
    private var isLoop: Bool = true

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        clipsToBounds = true
        addSubview(scrollView)
        addSubview(pageControl)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = CGSize(width: bounds.width * CGFloat(imageViews.count), height: bounds.height)
        for (i, iv) in imageViews.enumerated() {
            iv.frame = CGRect(x: bounds.width * CGFloat(i), y: 0, width: bounds.width, height: bounds.height)
        }
    }

    // MARK: - Data

    private func reloadData() {
        // 清除旧视图
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()

        guard !items.isEmpty else {
            pageControl.numberOfPages = 0
            stopTimer()
            return
        }

        // 循环：在首尾各添加一个额外视图
        var displayItems = items
        if isLoop && items.count > 1 {
            let last = items.last!
            let first = items.first!
            displayItems.insert(last, at: 0)
            displayItems.append(first)
        }

        for item in displayItems {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.isUserInteractionEnabled = true

            if let imageURL = item.imageURL {
                ImageLoader.shared.load(iv, url: imageURL)
            } else {
                iv.image = item.image
            }

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            iv.addGestureRecognizer(tap)
            scrollView.addSubview(iv)
            imageViews.append(iv)
        }

        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0

        // 初始位置
        if isLoop && items.count > 1 {
            scrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false)
        }

        setNeedsLayout()
        layoutIfNeeded()
        setupTimer()
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let index = imageViews.firstIndex(of: gesture.view as! UIImageView) else { return }
        var realIndex: Int
        if isLoop && items.count > 1 {
            realIndex = (index - 1 + items.count) % items.count
        } else {
            realIndex = index
        }
        onItemClick?(items[realIndex], realIndex)
    }

    // MARK: - Timer

    private func setupTimer() {
        stopTimer()
        guard autoScrollInterval > 0 && items.count > 1 else { return }

        timer = Timer.scheduledTimer(timeInterval: autoScrollInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func autoScroll() {
        let targetX = scrollView.contentOffset.x + bounds.width
        scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
    }

    deinit {
        stopTimer()
    }
}

// MARK: - UIScrollViewDelegate

extension CarouselView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard bounds.width > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / bounds.width))

        if isLoop && items.count > 1 {
            let realPage = (page - 1 + items.count) % items.count
            if currentPage != realPage {
                currentPage = realPage
                pageControl.currentPage = realPage
            }
        } else {
            let realPage = max(0, min(page, items.count - 1))
            currentPage = realPage
            pageControl.currentPage = realPage
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustOffsetIfNeeded()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        adjustOffsetIfNeeded()
    }

    private func adjustOffsetIfNeeded() {
        guard isLoop && items.count > 1 && bounds.width > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / bounds.width))
        if page == 0 {
            // 在第一个额外页，跳到最后真实页
            scrollView.setContentOffset(CGPoint(x: bounds.width * CGFloat(items.count), y: 0), animated: false)
        } else if page == items.count + 1 {
            // 在最后一个额外页，跳到第一个真实页
            scrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false)
        }
    }
}
