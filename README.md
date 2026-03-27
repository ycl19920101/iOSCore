# iOSCore

iOS 常用工具库，提供扩展、工具类和 UI 组件。

## 安装方式

### CocoaPods

在 Podfile 中添加：

```ruby
pod 'iOSCore', :git => 'https://github.com/ycl19920101/iOSCore.git'
```

或发布到 CocoaPods 后：

```ruby
pod 'iOSCore'
```

### Swift Package Manager

在 Xcode 中：
1. File → Add Packages...
2. 输入仓库地址：`https://github.com/ycl19920101/iOSCore.git`
3. 选择版本规则

或在 Package.swift 中：

```swift
dependencies: [
    .package(url: "https://github.com/ycl19920101/iOSCore.git", from: "0.1.0")
]
```

## 使用方法

```swift
import iOSCore

// 使用框架功能
```

## 要求

- iOS 12.0+
- Swift 5.0+

## 许可证

iOSCore 基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
