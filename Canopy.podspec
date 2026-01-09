Pod::Spec.new do |s|
  s.name             = 'Canopy'
  s.version          = '0.2.0'
  s.summary          = 'A lightweight, high-performance logging framework for iOS'
  s.description      = <<-DESC
Canopy is a logging framework inspired by Android's Timber, using a Tree-based architecture.
It provides zero-overhead logging in Release mode and is compatible with iOS 14+.

Features:
- Tree-based architecture for flexible logging
- Performance optimized (zero overhead in Release mode when only DebugTree is used)
- iOS 14+ support
- No external dependencies
                   DESC

  s.homepage         = 'https://github.com/ding1dingx/Canopy'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'syxc' => 'nian1.wiki@gmail.com' }
  s.source           = { :git => 'git@github.com:ding1dingx/Canopy.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation'
end
