//
//  KeyboardSearchInteraction.swift
//  MobileNav
//
//  Created by James Lapinski on 5/19/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import MapKit
import SmartDeviceLink
import UIKit

class KeyboardSearchInteraction: NSObject {
    private let screenManager: SDLScreenManager
    private var mapInteraction: MapItemsListInteraction?
    private var voiceSearchInteraction: VoiceSearchInteraction?
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
            searchManager.searchFor(searchTerm: inputText) { (mapItems, error) in
                if error != nil {
                    Alert.presentSearchErrorAlert()
                    return
                }

                if let mapItems = mapItems {
                    self.mapInteraction = MapItemsListInteraction(screenManager: self.screenManager, searchText: inputText, mapItems: mapItems)
                    self.mapInteraction?.present()
                }
            }
        case .voice:
            voiceSearchInteraction = VoiceSearchInteraction(screenManager: self.screenManager)
            voiceSearchInteraction?.present()
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
