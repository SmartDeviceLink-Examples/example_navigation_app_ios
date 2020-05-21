//
//  Alert.swift
//  MobileNav
//
//  Created by James Lapinski on 5/20/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import SmartDeviceLink

class Alert {
    private static let defaultDuration = 5000 as NSNumber
    private static var okSoftButton: SDLSoftButton {
        return SDLSoftButton(type: .text, text: "OK", image: nil, highlighted: false, buttonId: nextAlertSoftButtonId(), systemAction: nil, handler: nil)
    }
    private static var alertSoftButtonId = UInt16(10000)
    private static func nextAlertSoftButtonId() -> UInt16 {
        Alert.alertSoftButtonId += 1
        return Alert.alertSoftButtonId
    }

    class func presentSearchErrorAlert() {
        let alert = SDLAlert()
        alert.duration = defaultDuration
        alert.alertText1 = "An error occurred"
        alert.alertText2 = "Please try again"
        alert.softButtons = [okSoftButton]
        alert.ttsChunks = [SDLTTSChunk(text: "An error occured", type: .text)]

        ProxyManager.sharedManager.sdlManager.send(request: alert)
    }

    class func presentUnableToFindLocation() {
        let alert = SDLAlert()
        alert.duration = defaultDuration
        alert.alertText1 = "Unable to find your location"
        alert.alertText2 = "Please ensure location is enabled and try again"
        alert.softButtons = [okSoftButton]
        alert.ttsChunks = [SDLTTSChunk(text: "Unable to find your location", type: .text)]

        ProxyManager.sharedManager.sdlManager.send(request: alert)
    }
}
