Pod::Spec.new do |s|
  s.name             = "CRPermissions"
  s.version          = "1.0"
  s.summary          = "UIViewController with delegate methods that give an aesthetically pleasing way to request system permissions from your users."
  s.description      = <<-DESC
                       UIViewController with delegate methods that give an aesthetically pleasing way to request system permissions from your users.
                       DESC
  s.homepage         = "http://codywinton.com/"
  s.screenshots      = "http://f.cl.ly/items/2I1V1R3b3q3A3H3y3u18/new-1.jpg"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Cody Winton" => "cody.t.winton@gmail.com" }
  s.source           = { :git => "https://github.com/codywinton/CRPermissions.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://twitter.com/codytwinton'

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.frameworks   = ['AddressBook', 'AssetsLibrary', 'AVFoundation', 'CoreLocation', 'EventKit']

  s.source_files = 'CRPermissions/*.swift'
end