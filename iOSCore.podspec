Pod::Spec.new do |s|
  s.name             = 'iOSCore'
  s.version          = '1.0.0'
  s.summary          = 'iOS 常用工具库'
  s.description      = <<-DESC
iOSCore 提供了 iOS 开发中常用的扩展、工具类和 UI 组件。
包含网络请求、存储、加密、事件总线、路由、缓存等核心模块，
以及可选的 UI 组件子模块。
                       DESC

  s.homepage         = 'https://github.com/ycl19920101/iOSCore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ycl19920101' => 'your@email.com' }
  s.source           = { :git => 'https://github.com/ycl19920101/iOSCore.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.4'
  s.swift_version = '5.0'
  s.static_framework = true

  s.default_subspecs = ['Core']

  # Core 子模块（网络/存储/加密/事件/路由/缓存/更新等）
  s.subspec 'Core' do |core|
    core.source_files = 'iOSCore/iOSCore/Core/**/*.swift'
    core.dependency 'Alamofire', '~> 5.8'
    core.dependency 'Kingfisher', '~> 8.0'
    core.dependency 'SwiftyBeaver', '~> 2.0'
    core.dependency 'KeychainAccess', '~> 4.2'
  end

  # UI 子模块（基础 VC、WebView、轮播、Alert 等）
  s.subspec 'UI' do |ui|
    ui.source_files = 'iOSCore/iOSCore/UI/**/*.swift'
    ui.dependency 'iOSCore/Core'
  end
end
