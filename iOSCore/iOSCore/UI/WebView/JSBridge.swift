//
//  JSBridge.swift
//  iOSCore
//
//  Created by Chunlin Yao on 2026/4/14.
//

import Foundation
import WebKit

/// JS-Native 桥接
public final class JSBridge {

    /// 桥接处理闭包
    public typealias Handler = ([String: Any]) -> Void

    private var handlers: [String: Handler] = [:]
    private var webView: WKWebView?

    /// 注册 JS 调用处理
    public func register(_ name: String, handler: @escaping Handler) {
        handlers[name] = handler
    }

    /// 注入到 WebView
    public func attach(to webView: WKWebView) {
        self.webView = webView

        let contentController = webView.configuration.userContentController
        for name in handlers.keys {
            contentController.add(ScriptMessageDelegate { [weak self] message in
                self?.handleMessage(message)
            }, name: name)
        }
    }

    /// 从 WebView 注销
    public func detach() {
        guard let webView = webView else { return }
        let contentController = webView.configuration.userContentController
        for name in handlers.keys {
            contentController.removeScriptMessageHandler(forName: name)
        }
        self.webView = nil
    }

    /// Native 调用 JS
    public func callJS(_ functionName: String, args: Any? = nil, completion: ((Any?) -> Void)? = nil) {
        let jsString: String
        if let args = args {
            if let data = try? JSONSerialization.data(withJSONObject: args),
               let jsonString = String(data: data, encoding: .utf8) {
                jsString = "\(functionName)(\(jsonString))"
            } else {
                jsString = "\(functionName)()"
            }
        } else {
            jsString = "\(functionName)()"
        }

        webView?.evaluateJavaScript(jsString) { result, _ in
            completion?(result)
        }
    }

    // MARK: - Private

    private func handleMessage(_ message: WKScriptMessage) {
        guard let handler = handlers[message.name] else { return }
        if let body = message.body as? [String: Any] {
            handler(body)
        } else {
            handler(["data": message.body])
        }
    }
}

// MARK: - ScriptMessageDelegate

private class ScriptMessageDelegate: NSObject, WKScriptMessageHandler {
    private let handler: (WKScriptMessage) -> Void

    init(handler: @escaping (WKScriptMessage) -> Void) {
        self.handler = handler
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler(message)
    }
}
