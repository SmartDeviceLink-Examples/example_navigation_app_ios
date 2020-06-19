//
//  AppDelegate.swift
//  MobileNav
//
//  Created by James Lapinski on 4/3/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import Mapbox
import Speech

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let locationManager: LocationManager
    private var sdlTouchManager: SDLMapViewTouchManager?

    override init() {
        locationManager = LocationManager()
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Register MapBox Access Token by looking for keys.plist file. This must be done before creating an instance of MGLMapView otherwise the map view may not load.
        SecretValues.setAccessToken()

        window = UIWindow(frame: UIScreen.main.bounds)
        let mapBoxStoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! MapBoxViewController

        mapBoxStoryboard.setupLocationManager(locationManager)

        SFSpeechRecognizer.requestAuthorization { _ in }

        self.window?.rootViewController = mapBoxStoryboard
        self.window?.makeKeyAndVisible()

        // Get the SDL app video stream settings
        AppUserDefaults.setDefaults()
        let streamSettings = StreamSettings(renderType: AppUserDefaults.shared.renderType!, streamType:AppUserDefaults.shared.streamType!)

        // Start the SDL app. This will start looking for a connection with an SDL enabled accessory.
        ProxyManager.sharedManager.connect(with: SDLAppConstants.connectionType, streamSettings: streamSettings, locationManager: locationManager)

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Start looking for notifications
        NotificationQueue.shared.start()
    }
}

