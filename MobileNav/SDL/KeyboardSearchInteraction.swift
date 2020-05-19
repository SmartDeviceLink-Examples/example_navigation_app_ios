//
//  KeyboardSearchInteraction.swift
//  MobileNav
//
//  Created by James Lapinski on 5/19/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink
import MapKit

class KeyboardSearchInteraction: NSObject {
    private let screenManager: SDLScreenManager
    private var mapInteraction: MapItemsListInteraction?
//    private var voiceSearchInteraction: VoiceSearchInteraction?
    let searchManager = SearchManager()

    init(screenManager: SDLScreenManager) {
        self.screenManager = screenManager
    }

    func present() {
        screenManager.presentKeyboard(withInitialText: "Search", delegate: self)
    }
}

extension KeyboardSearchInteraction: SDLKeyboardDelegate {
    func userDidSubmitInput(_ inputText: String, withEvent source: SDLKeyboardEvent) {
        switch source {
        case .submitted:
            let results = searchManager.getSearchResults(from: inputText)

            var okSoftButton: SDLSoftButton {
                return SDLSoftButton(type: .text, text: "OK", image: nil, highlighted: false, buttonId: 1, systemAction: nil, handler: nil)
            }

            guard !results.isEmpty else {
                let alert = SDLAlert()
                alert.duration = 5000 as NSNumber
                alert.alertText1 = "No search results for"
                alert.alertText2 = "\"\(inputText)\""
                alert.softButtons = [okSoftButton]
                alert.ttsChunks = [SDLTTSChunk(text: "No search results for \"\(inputText)\"", type: .text)]
                ProxyManager.sharedManager.sdlManager.send(request: alert)

                return
            }

            mapInteraction = MapItemsListInteraction(screenManager: screenManager, mapItems: results)
            mapInteraction?.present()
        case .voice:
            print("voice")
            // to do
        default:
            fatalError()
        }
    }

    func keyboardDidAbort(withReason event: SDLKeyboardEvent) {
        switch event {
        case .cancelled:
            print("user cancelled search")
        case .aborted:
            print("system aborted search")
        default:
            fatalError()
        }
    }
}
