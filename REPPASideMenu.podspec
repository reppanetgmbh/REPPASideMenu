#
# Be sure to run `pod lib lint REPPASideMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'REPPASideMenu'
  s.version          = '1.0.0'
  s.summary          = 'REPPASideMenu is a simple animated navigation menu written in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
REPPASideMenu allows for custom navigation menus in iOS applications with configurable animations. All written in Swift.
                       DESC

  s.homepage         = 'https://github.com/reppanetgmbh/REPPASideMenu'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'alex.stonehouse@gmail.com' => 'as@reppa.net' }
  s.source           = { :git => 'https://github.com/reppanetgmbh/REPPASideMenu.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'REPPASideMenu/Classes/**/*'
  
  # s.resource_bundles = {
  #   'REPPASideMenu' => ['REPPASideMenu/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
