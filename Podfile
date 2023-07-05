# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'

target 'MobileNav' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MobileNav
#  pod 'SmartDeviceLink/Swift', :git => 'https://github.com/smartdevicelink/sdl_ios.git', :branch => 'bugfix/issue-2011-fix-sdlvideostreamingrange'
  pod 'SmartDeviceLink/Swift', '~> 7.6.1'
  pod 'Mapbox-iOS-SDK', '~> 5.7'
end

# Set pods min deployment target
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end
end
