Pod::Spec.new do |s|
  s.name         = "KZRobot"
  s.version      = "0.0.1"
  s.summary      = "Objective-C based Network Protocol Testing Framework"
  s.homepage     = "https://github.com/kaazing/robot.ios"
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = { "Prashant Khanal" => "prashantkhanal@gmail.com" }
  s.ios.platform = :ios, '5.0'
  s.ios.deployment_target = "5.0"
  s.framework    = 'XCTest'
  s.source       = { :git => "https://github.com/kaazing/robot.ios.git", :tag => s.version.to_s}

  s.source_files  = 'KZRobot/*.h', 'KZRobot/Robot/*.{h,m}', 'KZRobot/Robot/Command/*.{h,m}', 'KZRobot/Robot/Event/*.{h,m}'
  s.public_header_files = 'KZRobot/KZRobot.h', 'KZRobot/Robot/XCRoboticTestCase.h
  s.requires_arc = true
end
