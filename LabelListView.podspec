Pod::Spec.new do |spec|

  spec.name         = "LabelListView"
  spec.version      = "0.1"
  spec.summary      = "Swift自动布局实现的标签列表视图"
  spec.description  = "Swift自动布局实现的标签列表视图"

  spec.homepage     = "https://github.com/tuxi/LabelListView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "xiaoyuan" => "seyooe@gmail.com" }
  spec.social_media_url   = "https://twitter.com/seyooe"

  spec.platform = :ios
  spec.ios.deployment_target = '10.0'
  spec.source       = { :git => "https://github.com/tuxi/LabelListView.git", :tag => "#{spec.version}" }

  spec.source_files  = "Source/**/*.{swift}"

  spec.framework  = "UIKit"
  spec.swift_version  = '5.0'

end
