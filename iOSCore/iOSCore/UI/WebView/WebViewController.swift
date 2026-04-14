//
//  WebViewController.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import UIKit
import WebKit

/// WebView 控制器
open class WebViewController: BaseViewController {

    /// URL
    public let url: URL

    /// WebView
    public private(set) lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.allowsBackForwardNavigationGestures = true
        return web
    }()

    /// 进度条
    private lazy var progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = .clear
        pv.progressTintColor = view.tintColor
        return pv
    }()

    /// JSBridge
    public let jsBridge = JSBridge()

    // MARK: - Init

    public init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    public convenience init(urlString: String) {
        self.init(url: URL(string: urlString) ?? URL(string: "about:blank")!)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    open override func setupUI() {
        super.setupUI()

        view.addSubview(webView)
        view.addSubview(progressView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
        ])

        // 进度观察
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        // 加载 URL
        webView.load(URLRequest(url: url))
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView.setProgress(progress, animated: true)
            if progress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                    self.progressView.alpha = 0
                }) { _ in
                    self.progressView.setProgress(0, animated: false)
                }
            }
        }
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    // MARK: - JS 调用

    /// 执行 JS
    public func evaluateJS(_ script: String, completion: ((Any?, Error?) -> Void)? = nil) {
        webView.evaluateJavaScript(script) { result, error in
            completion?(result, error)
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 子类可重写拦截 URL
        decisionHandler(.allow)
    }

    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 标题同步
        title = webView.title
    }
}
