Pod::Spec.new do |s|
  s.name             = 'iOSCore'
  s.version          = '0.1.0'
  s.summary          = 'iOS 常用工具库'
  s.description      = <<-DESC
iOSCore 提供了 iOS 开发中常用的扩展、工具类和 UI 组件。
                       DESC

  s.homepage         = 'https://github.com/ycl19920101/iOSCore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ycl19920101' => 'your@email.com' }
  s.source           = { :git => 'https://github.com/ycl19920101/iOSCore.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.4'
  s.swift_version = '5.0'
  s.static_framework = true

  s.source_files = 'iOSCore/iOSCore/**/*.swift'

  # 如果有资源文件
  # s.resource_bundles = {
  #   'iOSCore' => ['iOSCore/iOSCore/Assets/**/*']
  # }

  # 依赖其他库
  s.dependency 'Alamofire', '~> 5.8'
  s.dependency 'Kingfisher', '~> 8.0'
  s.dependency 'SwiftyBeaver', '~> 2.0'
  s.dependency 'KeychainAccess', '~> 4.2'
end
