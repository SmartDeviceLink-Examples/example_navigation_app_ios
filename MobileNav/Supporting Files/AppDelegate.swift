//
//  AppDelegate.swift
//  MobileNav
//
//  Created by James Lapinski on 4/3/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import Mapbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)

        if let url = Bundle.main.url(forResource: "keys", withExtension: "plist") {
            do {
              let data = try Data(contentsOf:url)
              let keysDictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:String]
                MGLAccountManager.accessToken = keysDictionary["MGLMapboxAccessToken"]
            } catch {
               print(error)
            }
        }

        // Default stream settings
        AppUserDefaults.setDefaults()

        let streamSettings = StreamSettings(renderType: AppUserDefaults.shared.renderType!, streamType:AppUserDefaults.shared.streamType!, viewControllerToStream: (UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? MapBoxViewController)!)
        ProxyManager.sharedManager.connect(with: SDLAppConstants.connectionType, streamSettings: streamSettings)

        let mapBoxStoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! MapBoxViewController
        self.window?.rootViewController = mapBoxStoryboard
        self.window?.makeKeyAndVisible()

        return true
    }

}

