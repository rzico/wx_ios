#
# Be sure to run `pod lib lint CJBaseCategory.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CJBaseCategory'
  s.version          = '0.1.0'
  s.summary          = 'CJBaseCategory.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
			A framework for category.
                       DESC

  s.homepage         = 'https://github.com/rzrcj/CJBaseCategory'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CJ' => 'admin@rzrcj.com.cn' }
  s.source           = { :path => '.' }

  s.ios.deployment_target = '8.0'
  s.platform = :ios, "8.0"
  s.source_files = 'CJBaseCategory/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'CJBaseCategory' => ['CJBaseCategory/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
