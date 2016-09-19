#
# Be sure to run `pod lib lint ANPlayerController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ANPlayerController'
  s.version          = '3.0.0'
  s.summary          = 'A short description of ANPlayerController.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/ANPlayerController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sergey Demchenko' => 'antrix1989@gmail.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/ANPlayerController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ANPlayerController/Classes/**/*'
  
#s.resource_bundles = {
#    'ANPlayerController' => ['ANPlayerController/Assets/*.{storyboard,xib,xcassets,json,imageset,png}']
#  }
  s.resource = 'ANPlayerController/Assets/ANPlayerImages.xcassets'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit', '>= 3.0.0'
end
