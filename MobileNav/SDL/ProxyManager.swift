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

enum ProxyState {
    case stopped
    case searching
    case connected
}

class ProxyManager: NSObject {

    public private(set) var sdlManager: SDLManager!
    static let sharedManager = ProxyManager()
    private var isOffScreen = false
    var proxyState = ProxyState.stopped
    var rpcVersion: Int?

    private override init() {
        super.init()
        registerForNotifications()
    }

    func connect(with connectionType: ConnectionType, streamSettings: StreamSettings) {
        proxyState = .searching
        if streamSettings.streamType == .offScreen {
            isOffScreen = true
        } else {
            isOffScreen = false
        }

        if sdlManager == nil {
            sdlManager = SDLManager(configuration: connectionType == .iap ? ProxyManager.connectIAP(streamSettings: streamSettings) : ProxyManager.connectTCP(streamSettings: streamSettings), delegate:self)
        }

        sdlManager.start { (success, error) in
            if success {
                self.proxyState = .connected
                self.rpcVersion = ProxyManager.sharedManager.sdlManager.registerResponse?.sdlMsgVersion?.majorVersion.intValue
            } else {
                print("SDL Connection Error: \(error!)")
            }
        }
    }

    func stopConnection() {
        guard sdlManager != nil else {
            proxyState = .stopped
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.sdlManager.stop()
        }

        proxyState = .stopped
    }

    class func connectIAP(streamSettings:StreamSettings) -> SDLConfiguration {
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: SDLAppConstants.appName, fullAppId: SDLAppConstants.appId)
        return setupConfiguration(with: lifecycleConfiguration, streamSettings: streamSettings)
    }

    class func connectTCP(streamSettings:StreamSettings) -> SDLConfiguration {
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: SDLAppConstants.appName, fullAppId: SDLAppConstants.appId, ipAddress: SDLAppConstants.ipAddress, port: SDLAppConstants.port)
        return setupConfiguration(with: lifecycleConfiguration, streamSettings: streamSettings)
    }

    class func setupConfiguration(with lifecycleConfiguration: SDLLifecycleConfiguration, streamSettings:StreamSettings) -> SDLConfiguration {
        if let appLogo = UIImage(named: "icon") {
            let appIcon = SDLArtwork(image: appLogo, name: "icon", persistent: true, as: .PNG)
            lifecycleConfiguration.appIcon = appIcon
        }
        
        lifecycleConfiguration.appType = .navigation
        let lockscreenConfig = SDLLockScreenConfiguration.enabled()

        return SDLConfiguration(lifecycle: lifecycleConfiguration, lockScreen: lockscreenConfig, logging: ProxyManager.logConfiguration(), streamingMedia:ProxyManager.streamingMediaConfiguration(streamSettings: streamSettings), fileManager: .default(), encryption: nil)
    }

    class func logConfiguration() -> SDLLogConfiguration {
        let logConfig = SDLLogConfiguration.debug()
        logConfig.globalLogLevel = .debug
        return logConfig
    }

    class func streamingMediaConfiguration(streamSettings: StreamSettings) -> SDLStreamingMediaConfiguration {
        let streamingMediaConfig = SDLStreamingMediaConfiguration.autostreamingInsecureConfiguration(withInitialViewController: streamSettings.viewControllerToStream)
        streamingMediaConfig.carWindowRenderingType = getSDLRenderType(from: streamSettings.renderType)

        return streamingMediaConfig
    }

    class func getSDLRenderType(from renderType:RenderType) -> SDLCarWindowRenderingType {
        switch renderType {
        case .layer: return .layer
        case .viewAfterScreenUpdates: return .viewAfterScreenUpdates
        case .viewBeforeScreenUpdates: return .viewBeforeScreenUpdates
        }
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
        if proxyState != .stopped {
            proxyState = .searching
        }

        if isOffScreen {
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: .offScreenDisconnected))
            }
        }
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

        if oldLevel == .none && newLevel == .full && isOffScreen {
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: .offScreenConnected))
            }
        }
    }
}
