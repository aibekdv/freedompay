#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint freedompay.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'freedompay'
  s.version          = '0.0.1'
  s.summary          = 'FreedomPay Flutter plugin using PayBoxSdk.'
  s.description      = <<-DESC
A Flutter plugin that integrates PayBoxSdk for iOS payments.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 'Pods/PayBoxSdk/PayBoxSdk/**/*.{h,m,swift}'
  s.dependency 'Flutter'
  s.dependency 'PayBoxSdk'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
  s.requires_arc = true
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
