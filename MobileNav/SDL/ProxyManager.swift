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

    public private(set) var sdlManager: SDLManager!
    static let sharedManager = ProxyManager()

    private override init() {
        super.init()
        registerForNotifications()
    }

    func connect(with connectionType: ConnectionType, streamSettings: StreamSettings) {
        sdlManager = SDLManager(configuration: connectionType == .iap ? ProxyManager.connectIAP() : ProxyManager.connectTCP(), delegate:self)

        sdlManager.start { (success, error) in
            if success {
                // app has succussfully connected
            } else {
                print("SDL Connection Error: \(error!)")
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
        if let appLogo = UIImage(named: "icon") {
            let appIcon = SDLArtwork(image: appLogo, name: "icon", persistent: true, as: .PNG)
            lifecycleConfiguration.appIcon = appIcon
        }
        lifecycleConfiguration.appType = .navigation
        let lockscreenConfig = SDLLockScreenConfiguration.enabled()
        lockscreenConfig.displayMode = .always

        return SDLConfiguration(lifecycle: lifecycleConfiguration, lockScreen: .enabled(), logging: ProxyManager.logConfiguration(), streamingMedia:ProxyManager.streamingMediaConfiguration(), fileManager: .default(), encryption: nil)
    }

    class func logConfiguration() -> SDLLogConfiguration {
        let logConfig = SDLLogConfiguration.debug()
        logConfig.globalLogLevel = .debug
        return logConfig
    }

    class func streamingMediaConfiguration() -> SDLStreamingMediaConfiguration {
        let mapViewController = UIStoryboard(name: "SDLMapBoxMap", bundle: nil).instantiateInitialViewController() as? MapBoxViewController
        let streamingMediaConfig = SDLStreamingMediaConfiguration .autostreamingInsecureConfiguration(withInitialViewController: mapViewController!)
        streamingMediaConfig.carWindowRenderingType = .viewAfterScreenUpdates

        return streamingMediaConfig
    }

}

private extension ProxyManager {
    func registerForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(sdlVideoStreamDidStart), name: .SDLVideoStreamDidStart, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sdlVideoStreamDidStop), name: .SDLVideoStreamDidStop, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sdlVideoStreamSuspended), name: .SDLVideoStreamSuspended, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sdlAudioStreamDidStart), name: .SDLAudioStreamDidStart, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sdlAudioStreamDidStop), name: .SDLAudioStreamDidStop, object: nil)
    }

    @objc func sdlVideoStreamDidStart() {
        DispatchQueue.main.async {
            SDLLog.d("Starting video")
        }
    }

    @objc func sdlVideoStreamDidStop() {
        DispatchQueue.main.async {
            SDLLog.d("Stopping video")
        }
    }

    @objc func sdlVideoStreamSuspended() {
        DispatchQueue.main.async {
            SDLLog.d("Suspending video")
        }
    }

    @objc func sdlAudioStreamDidStart() {
        DispatchQueue.main.async {
            SDLLog.d("Starting audio")
        }
    }

    @objc func sdlAudioStreamDidStop() {
        DispatchQueue.main.async {
             SDLLog.d("Stopping audio")
        }
    }
}

extension ProxyManager: SDLManagerDelegate {
    func managerDidDisconnect() {

    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        if newLevel != .none {
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
}
