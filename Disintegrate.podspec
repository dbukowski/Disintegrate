#
# Be sure to run `pod lib lint Disintegrate.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Disintegrate'
  s.version          = '0.1.0'
  s.summary          = 'Disintegration animation inspired by THAT thing Thanos did at the end of Avengers: Infinity War.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Disintegrate is a small library providing an animation inspired by how our favorite heroes disappeared at the end of Avengers: Infinity War.
    The view or layer that you use it on is divided into small triangles, which then move into one direction and fade away. You can customize
    the estimated number of triangles and the direction they will move to.
                       DESC

  s.homepage         = 'https://github.com/dbukowski/Disintegrate'
  s.screenshots      = 'https://imgur.com/kPXjfNP', 'https://imgur.com/bz7zFez', 'https://imgur.com/EnYu6uJ', 'https://imgur.com/bNWiGrD', 'https://imgur.com/kytYTMT'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dariusz Bukowski' => 'dariusz.m.bukowski@gmail.com' }
  s.source           = { :git => 'https://github.com/dbukowski/Disintegrate.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/darekbukowski'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Disintegrate/Classes/**/*'
end
