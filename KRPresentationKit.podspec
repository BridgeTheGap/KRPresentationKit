#
# Be sure to run `pod lib lint KRPresentationKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KRPresentationKit'
  s.version          = '0.6.3'
  s.summary          = 'A custom animation modal presentation library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
KRPresentationKit makes custom modal presentation easy by providing useful default animations,
as well as the functionality to define a custom animation.
                       DESC

  s.homepage         = 'https://github.com/BridgeTheGap/KRPresentationKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Josh Woomin Park' => 'wmpark@knowre.com' }
  s.source           = { :git => 'https://github.com/BridgeTheGap/KRPresentationKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'KRPresentationKit/Classes/**/*'
  s.dependency 'KRAnimationKit'

  # s.resource_bundles = {
  #   'KRPresentationKit' => ['KRPresentationKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

end
