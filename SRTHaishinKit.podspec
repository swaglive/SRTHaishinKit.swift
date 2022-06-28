Pod::Spec.new do |spec|
  spec.name         = "SRTHaishinKit"
  spec.version      = "0.0.2"
  spec.summary      = "Camera and Microphone streaming library via SRT for iOS."
  spec.swift_version = "5.5"

  spec.description  = <<-DESC
  Camera and Microphone streaming library via SRT for iOS.
                   DESC

  spec.homepage     = "https://github.com/shogo4405/SRTHaishinKit.swift"
  spec.license      = "New BSD"
  spec.author       = { "shogo4405" => "shogo4405@gmail.com" }

  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/swaglive/SRTHaishinKit.swift.git", :tag => "#{spec.version}" }

  spec.public_header_files = 'Platforms/iOS/SRTHaishinKit.h'
  spec.private_header_files = 'Vendor/SRT/Includes/*.h'
  spec.source_files  = [
    'Sources/**/*.swift',
    'Platforms/iOS/**/*.h',
    'Vendor/SRT/Includes/*.h'
  ]
  spec.dependency 'Logboard', '~> 2.2.2'
  spec.dependency 'HaishinKit'
  spec.dependency 'OpenSSL-Universal', '~> 1.1.1501'
  spec.library = 'c++'
  spec.preserve_paths = [
    'Platforms/iOS/**/*.modulemap',
    'Vendor/SRT/**/libsrt-iOS.a'
  ]  

  spec.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS' => '"${PODS_TARGET_SRCROOT}/Platforms/iOS/Supporting Files"',
    'LIBRARY_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"/Vendor/SRT',
    'OTHER_LDFLAGS' => '-lsrt-iOS'
  }  

end
