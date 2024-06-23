Pod::Spec.new do |s|
    s.name         = "DYFStoreKit"
    s.version      = "2.2.0"
    s.summary      = "[ObjC] A lightweight and easy-to-use iOS library for In-App Purchases."
    
    s.description  = <<-DESC
    TODU: [ObjC] A lightweight and easy-to-use iOS library for In-App Purchases. DYFStoreKit uses blocks and notifications to wrap StoreKit, provides receipt verification and transaction persistence.
    DESC
    
    s.homepage = "https://github.com/itenfay/DYFStoreKit"
    s.source = { :git => "https://github.com/itenfay/DYFStoreKit.git", :tag => s.version.to_s }
    # s.screenshots = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
    
    # s.license = "MIT (example)"
    s.license = { :type => "MIT", :file => "LICENSE" }
    
    s.author             = { "Tenfay" => "itenfay@163.com" }
    # Or just: s.author  = "Tenfay"
    # s.authors          = { "Tenfay" => "itenfay@163.com" }
    # s.social_media_url = "https://twitter.com/Tenfay"
    
    s.platform     = :ios
    # s.platform   = :ios, "5.0"
    s.ios.deployment_target       = "7.0"
    # s.osx.deployment_target     = "10.10"
    # s.watchos.deployment_target = "3.0"
    # s.tvos.deployment_target    = "9.0"
    
    s.requires_arc = true
    
    s.source_files = "Classes/*.{h,m}"
    s.public_header_files = "Classes/*.h"
    
    # s.exclude_files = "Classes/Exclude"
    # s.resource  = "icon.png"
    # s.resources = "Resources/*.png"
    
    s.framework = "StoreKit"
    # s.frameworks  = "Security", "StoreKit"
    # s.library   = "iconv"
    # s.libraries = "iconv", "xml2"
    # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
    
    # s.dependency 'JSONKit', '~> 1.4'
    # s.dependency 'DYFStoreReceiptVerifier'
    s.dependency 'DYFRuntimeProvider'
end
