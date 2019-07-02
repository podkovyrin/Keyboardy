Pod::Spec.new do |s|
  s.name             = "Keyboardy"
  s.version          = "0.2.6"
  s.summary          = "UIViewController extension for convenient keyboard management."
  s.description      = <<-DESC
                       Keyboardy extends UIViewController with few simple methods and provides delegate for handling keyboard appearance notifications.
                       DESC
  s.homepage         = "https://github.com/podkovyrin/Keyboardy"
  s.license          = 'MIT'
  s.author           = { "Andrew Podkovyrin" => "podkovyrin@gmail.com" }
  s.source           = { :git => "https://github.com/podkovyrin/Keyboardy.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/podkovyr'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/**/*'

  s.frameworks = 'UIKit'
end
