//
//  ProxyManager.swift
//  MobileNav
//
//  Created by James Lapinski on 4/3/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import SmartDeviceLink
import UIKit

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
    static var isOffScreenStreaming = false
    public private(set) var proxyState = ProxyState.stopped
    public private(set) var rpcVersion: Int?
    public private(set) var menuManager: MenuManager!
    private var firstHMINotNil = true

    private override init() {
        super.init()
    }

    func connect(with connectionType: ConnectionType, streamSettings: StreamSettings, locationManager: LocationManager) {
        proxyState = .searching
        ProxyManager.isOffScreenStreaming = streamSettings.streamType == .offScreen ? true : false

        if sdlManager == nil {
            sdlManager = SDLManager(configuration: connectionType == .iap ? ProxyManager.connectIAP(streamSettings: streamSettings) : ProxyManager.connectTCP(streamSettings: streamSettings), delegate:self)
        }

        sdlManager.start { (success, error) in
            if success {
                self.proxyState = .connected
                self.rpcVersion = ProxyManager.sharedManager.sdlManager.registerResponse?.sdlMsgVersion?.majorVersion.intValue


                if let streamingVC = self.sdlManager.streamManager?.rootViewController as? MapBoxViewController {
                    streamingVC.setupLocationManager(locationManager)
                    streamingVC.setupSDLApp()
                }

                // If RPC version is 6.0, prepare built-in menu
                if self.rpcVersion != nil && self.rpcVersion! >= 6 {
                    self.menuManager = MenuManager(with: self.sdlManager)
                }
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

            // Need to set sdlManager to nil for change in StreamSettings to take effect
            self?.sdlManager = nil
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

        // Lock screen should always show
        lockscreenConfig.displayMode = .always

        return SDLConfiguration(lifecycle: lifecycleConfiguration, lockScreen: lockscreenConfig, logging: ProxyManager.logConfiguration(), streamingMedia:ProxyManager.streamingMediaConfiguration(streamSettings: streamSettings), fileManager: .default(), encryption: nil)
    }

    class func logConfiguration() -> SDLLogConfiguration {
        let logConfig = SDLLogConfiguration.debug()
        logConfig.globalLogLevel = .debug
        logConfig.areAssertionsDisabled = true
        return logConfig
    }

    class func streamingMediaConfiguration(streamSettings: StreamSettings) -> SDLStreamingMediaConfiguration {
        let streamingMediaConfig = SDLStreamingMediaConfiguration()
        streamingMediaConfig.carWindowRenderingType = getSDLRenderType(from: streamSettings.renderType)

        streamingMediaConfig.supportedPortraitStreamingRange = SDLVideoStreamingRange(minimumResolution: SDLImageResolution(width: 300, height: 500), maximumResolution: SDLImageResolution(width: UInt16.max, height: UInt16.max))
        streamingMediaConfig.supportedLandscapeStreamingRange = SDLVideoStreamingRange(minimumResolution: SDLImageResolution(width: 500, height: 300), maximumResolution: SDLImageResolution(width: UInt16.max, height: UInt16.max))
        streamingMediaConfig.delegate = ProxyManager.sharedManager.self

        // The video encoder is configured to use the module's preferred framerate and bitrate. If desired, you can provide your custom settings as well. The lowest quality settings between your settings and the module's settings will be used.
        // streamingMediaConfig.customVideoEncoderSettings = [kVTCompressionPropertyKey_ExpectedFrameRate as String: 15, kVTCompressionPropertyKey_AverageBitRate as String: 600000]

        guard let mapViewController = SDLViewControllers.map else {
            SDLLog.e("Error loading the SDL map view")
            return streamingMediaConfig
        }

        if isOffScreenStreaming {
            streamingMediaConfig.rootViewController = mapViewController
        } else {
            streamingMediaConfig.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        }

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

// MARK: - SDLStreamingVideoDelegate
extension ProxyManager: SDLStreamingVideoDelegate {
    func videoStreamingSizeDidUpdate(toSize displaySize: CGSize) {
        SDLLog.d("Video stream size updated to width: \(displaySize.width), height: \(displaySize.height)")
    }
}

// MARK: - SDLManagerDelegate
extension ProxyManager: SDLManagerDelegate {
    func managerDidDisconnect() {
        if proxyState != .stopped {
            proxyState = .searching
        }

        guard !firstHMINotNil else {
            return
        }

        firstHMINotNil = true
    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        if newLevel != .none {
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = true
            }

            firstHMINotNil = false
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
}
