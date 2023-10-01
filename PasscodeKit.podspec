Pod::Spec.new do |s|
  s.name = 'PasscodeKit'
  s.version = '1.0.4'
  s.license = 'MIT'

  s.summary = 'A lightweight and easy-to-use Passcode Kit for iOS.'
  s.homepage = 'https://relatedcode.com'
  s.author = { 'Related Code' => 'info@relatedcode.com' }

  s.source = { :git => 'https://github.com/relatedcode/PasscodeKit.git', :tag => s.version }
  s.source_files = 'PasscodeKit/Sources/*.swift'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  s.swift_version = '5.0'
  s.platform = :ios, '12.0'
  s.requires_arc = true
end
