#
# Be sure to run `pod lib lint CRPermissions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CRPermissions"
  s.version          = "0.9"
  s.summary          = "UIViewController with delegate methods that give an aesthetically pleasing way to request system permissions from your users."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  # s.description      = <<-DESC
  #                     DESC

  s.homepage         = "http://codywinton.com"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Cody Winton" => "cody.t.winton@gmail.com" }
  s.source           = { :git => "https://github.com/codywinton/CRPermissions.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/codytwinton'

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.frameworks   = ['AddressBook', 'AssetsLibrary', 'AVFoundation', 'Contacts', 'CoreLocation', 'EventKit', 'UIKit']

  s.source_files = 'CRPermissions/*.swift'
  s.resource_bundles = {
    'CRPermissions' => ['CRPermissions/Assets/*.png']
  }
  
  s.dependency 'FontAwesomeKit'
end