Pod::Spec.new do |s|

    s.name             = 'JSBannerView'
    s.version          = '1.1.1'
    s.summary          = '一个简便易用的Banner框架。'
  
    s.description      = <<-DESC
    一个简便易用的Banner框架，无需复杂的配置即可满足大多数需求
                         DESC
  
    s.homepage         = 'https://github.com/spirit-jsb/JSBannerView.git'
  
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
    s.author           = { 'spirit-jsb' => 'sibo_jian_29903549@163.com' }
  
    s.swift_version = '5.0'
  
    s.ios.deployment_target = '9.0'
  
    s.source           = { :git => 'https://github.com/spirit-jsb/JSBannerView.git', :tag => s.version.to_s }
    
    s.source_files = 'Sources/**/*.swift'
    
    s.subspec "Core" do |ss|
      ss.source_files = "Sources/Core/"
      ss.frameworks = 'UIKit', 'Foundation'
    end

    s.subspec "RxSwift" do |ss|
      ss.source_files = "Sources/RxBannerView/"
      ss.dependency "JSBannerView/Core"
      ss.dependency "RxSwift", "~> 4.0"
      ss.dependency "RxCocoa", "~> 4.0"
    end
  
  end