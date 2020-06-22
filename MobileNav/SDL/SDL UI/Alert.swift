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
        alert.alertText1 = "An error occurred performing your search"
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

    class func presentDriverDistraction() {
        let alert = SDLAlert()
        alert.duration = defaultDuration
        alert.ttsChunks = [SDLTTSChunk(text: "Feature disallowed while vehicle is in motion", type: .text)]

        ProxyManager.sharedManager.sdlManager.send(request: alert)
    }

    class func presentSpeechRecognizerDisallowedAlert() {
        let alert = SDLAlert()
        alert.alertText1 = "Voice Search Disallowed"
        alert.alertText2 = "Please go to settings in the app and enable it"
        alert.ttsChunks = SDLTTSChunk.textChunks(from: "Voice search disallowed, please go to settings in the app and enable it")
        alert.duration = defaultDuration
        alert.softButtons = [okSoftButton]

        ProxyManager.sharedManager.sdlManager.send(request: alert)
    }

    class func presentSpeechRecognizerBadLocaleAlert() {
        let alert = SDLAlert()
        alert.alertText1 = "Voice search is not available"
        alert.alertText2 = "Due to Apple limitations, voice search is not available while the app is in the background"
        alert.ttsChunks = SDLTTSChunk.textChunks(from: "Voice search is not available")
        alert.duration = defaultDuration
        alert.softButtons = [okSoftButton]

        ProxyManager.sharedManager.sdlManager.send(request: alert)
    }

    class func presentSpeechNotDetectedAlert() {
        let alert = SDLAlert()
        alert.duration = defaultDuration
        alert.alertText1 = "No speech detected. Please try voice search again."
        alert.softButtons = [okSoftButton]
        alert.ttsChunks = [SDLTTSChunk(text: "Sorry", type: .text)]

        ProxyManager.sharedManager.sdlManager.send(request: alert)
    }

    class func presentEmptySearchResultsAlert(searchTerm: String) {
        let alert = SDLAlert()
        alert.duration = defaultDuration
        alert.alertText1 = "No search results found for"
        alert.alertText2 = "\"\(searchTerm)\""
        alert.softButtons = [okSoftButton]
        alert.ttsChunks = [SDLTTSChunk(text: "No search results for \"\(searchTerm)\"", type: .text)]

        ProxyManager.sharedManager.sdlManager.send(request: alert)
    }
}
