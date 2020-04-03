//
//  ProxyManager.swift
//  MobileNav
//
//  Created by James Lapinski on 4/3/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink

enum ConnectionType {
    case tcp
    case iap
}

class ProxyManager: NSObject {

    static let sharedManager = ProxyManager()
    public private(set) var sdlManager: SDLManager!

    private override init() {
        super.init()
    }

    func connect(with connectionType: ConnectionType) {
        sdlManager = SDLManager(configuration: connectionType == .iap ? ProxyManager.connectIAP() : ProxyManager.connectTCP(), delegate:self)

        sdlManager.start { (success, error) in
            guard success else {
                SDLLog.e("There was an error while starting up: \(String(describing: error))")
                return
            }
        }
    }

    class func connectIAP() -> SDLConfiguration {
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: SDLAppConstants.appName, fullAppId: SDLAppConstants.appId)
        return setupConfiguration(with: lifecycleConfiguration)
    }

    class func connectTCP() -> SDLConfiguration {
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: SDLAppConstants.appName, fullAppId: SDLAppConstants.appId, ipAddress: SDLAppConstants.ipAddress, port: SDLAppConstants.port)
        return setupConfiguration(with: lifecycleConfiguration)
    }

    class func setupConfiguration(with lifecycleConfiguration: SDLLifecycleConfiguration) -> SDLConfiguration {
        lifecycleConfiguration.appType = .navigation
        if let appLogo = UIImage(named: "logo") {
            let appIcon = SDLArtwork(image: appLogo, name: "logo", persistent: true, as: .PNG)
            lifecycleConfiguration.appIcon = appIcon
        }

        return SDLConfiguration(lifecycle: lifecycleConfiguration, lockScreen: .enabled(), logging: .default(), streamingMedia:ProxyManager.streamingMediaConfiguration(), fileManager: .default(), encryption: .default())
    }

    class func streamingMediaConfiguration() -> SDLStreamingMediaConfiguration {
        let streamingMediaConfig = SDLStreamingMediaConfiguration()

        streamingMediaConfig.rootViewController = SDLCarWindowViewController()
        streamingMediaConfig.carWindowRenderingType = .viewAfterScreenUpdates

        return streamingMediaConfig
    }

}

extension ProxyManager: SDLManagerDelegate {
    func managerDidDisconnect() {

    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        if newLevel != .none {
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}
