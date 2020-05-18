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



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

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
        let streamSettings = StreamSettings(renderType: .viewAfterScreenUpdates, isOffScreen: true, viewControllerToStream: (UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? MapBoxViewController)!)
        ProxyManager.sharedManager.connect(with: .iap, streamSettings: streamSettings)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

