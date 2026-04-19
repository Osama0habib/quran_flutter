Pod::Spec.new do |s|
  s.name             = 'quran_bridge_ios'
  s.version          = '0.1.0'
  s.summary          = 'iOS implementation of quran_bridge.'
  s.homepage         = 'https://github.com/your-org/quran_bridge'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Your Org' => 'dev@your-org.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.swift'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.9'
end
