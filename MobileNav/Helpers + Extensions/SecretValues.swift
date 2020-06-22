//
//  SecretValues.swift
//  MobileNav
//
//  Created by James Lapinski on 5/21/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import Mapbox

struct SecretConstants {
    static let appIdKey = "AppID"
    static let appNameKey = "AppName"
    static let accessTokenKey = "MGLMapboxAccessToken"
}

class SecretValues {
    private static let plistUrl = Bundle.main.url(forResource: "keys", withExtension: "plist")

    class func setAccessToken() {
        guard let url = plistUrl else { return }
        do {
            let data = try Data(contentsOf:url)
            let keysDictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:String]
            MGLAccountManager.accessToken = keysDictionary[SecretConstants.accessTokenKey]
        } catch {
            print("No value exists for key: \(SecretConstants.accessTokenKey)")
        }
    }

    class func appID() -> String? {
        guard let url = plistUrl else { return nil }
        do {
            let data = try Data(contentsOf:url)
            let keysDictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:String]
            return keysDictionary[SecretConstants.appIdKey]
        } catch {
            print("No value exists for key: \(SecretConstants.appIdKey)")
            return nil
        }
    }

    class func appName() -> String? {
        guard let url = plistUrl else { return nil }
        do {
            let data = try Data(contentsOf:url)
            let keysDictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:String]
            return keysDictionary[SecretConstants.appNameKey]
        } catch {
            print("No value exists for key: \(SecretConstants.appNameKey)")
            return nil
        }
    }
}
