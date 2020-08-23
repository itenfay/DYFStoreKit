
Pod::Spec.new do |spec|

  spec.name         = "DYFStoreKit"
  spec.version      = "1.1.5"
  spec.summary      = "A lightweight and easy-to-use iOS library for In-App Purchases. (Objective-C)"

  spec.description  = <<-DESC
	A lightweight and easy-to-use iOS library for In-App Purchases. DYFStoreKit uses blocks and notifications to wrap StoreKit, provides receipt verification and transaction persistence and doesn't require any external dependencies.
                   DESC

  spec.homepage      = "https://github.com/dgynfi/DYFStoreKit"
  # spec.screenshots = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  # spec.license    = "MIT (example)"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "dyf" => "vinphy.teng@foxmail.com" }
  # Or just: spec.author  = "dyf"
  # spec.authors          = { "dyf" => "vinphy.teng@foxmail.com" }
  # spec.social_media_url = "https://twitter.com/dyf"

  spec.platform     = :ios
  # spec.platform   = :ios, "5.0"

  spec.ios.deployment_target       = "7.0"
  # spec.osx.deployment_target     = "10.10"
  # spec.watchos.deployment_target = "3.0"
  # spec.tvos.deployment_target    = "9.0"

  spec.source = { :git => "https://github.com/dgynfi/DYFStoreKit.git", :tag => spec.version }

  spec.source_files    = "DYFStoreKit/*.{h,m}"
  # spec.exclude_files = "Classes/Exclude"

  spec.public_header_files = "DYFStoreKit/*.h"

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.framework = "SomeFramework"
  spec.frameworks  = "Security", "StoreKit"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"

  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
