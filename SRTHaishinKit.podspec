Pod::Spec.new do |s|

  s.name          = "SRTHaishinKit"
  s.version       = "0.0.4"
  s.summary       = "Camera and Microphone streaming library via SRT for iOS."
  s.swift_version = "5.7"

  s.description  = <<-DESC
  SRTHaishinKit. Camera and Microphone streaming library via SRT for iOS.
  DESC

  s.homepage     = "https://github.com/shogo4405/SRTHaishinKit.swift"
  s.license      = "New BSD"
  s.author       = { "shogo4405" => "shogo4405@gmail.com" }
  s.authors      = { "shogo4405" => "shogo4405@gmail.com" }
  s.source       = { :git => "https://github.com/shogo4405/SRTHaishinKit.swift.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "11.0"
  s.ios.source_files = "Platforms/iOS/*.{h,swift}"

  s.source_files = ['Sources/**/*.{swift,h}', 'Vendor/SRT/Includes/*.h']
  s.public_header_files = 'Platforms/iOS/SRTHaishinKit.h'
  s.private_header_files = ['Vendor/SRT/Includes/*.h']
  s.vendored_frameworks = 'Vendor/SRT/libsrt.xcframework'
  s.library = 'c++'
  s.cocoapods_version = ">= 1.9.0"

  s.xcconfig = {
    'SWIFT_INCLUDE_PATHS' => '"${PODS_TARGET_SRCROOT}/Platforms/iOS/Supporting Files"',
  }

  s.dependency 'HaishinKit', '~> 1.4.2'

end
