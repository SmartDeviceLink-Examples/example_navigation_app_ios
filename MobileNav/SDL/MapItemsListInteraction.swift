//
//  MapItemsListInteraction.swift
//  MobileNav
//
//  Created by James Lapinski on 5/19/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import MapKit
import SmartDeviceLink
import UIKit

class MapItemsListInteraction: NSObject {
    private let cells: [SDLChoiceCell]
    private let screenManager: SDLScreenManager
    private let mapItems: [MKMapItem]
    private let searchText: String

    init(screenManager: SDLScreenManager, searchText: String, mapItems: [MKMapItem]) {
        self.cells = MapItemsListInteraction.createChoices(from: mapItems)
        self.screenManager = screenManager
        self.mapItems = mapItems
        self.searchText = searchText
    }

    private class func createChoices(from mapItems: [MKMapItem]) -> [SDLChoiceCell] {
        var cells = [SDLChoiceCell]()
        var choiceCell: SDLChoiceCell

        // Make duplicate place names unique
        var itemNames = [String]()
        for item in mapItems {
            if item.name != nil {
                itemNames.append(item.name!)
            }
        }
        let newArray = itemNames.sdl_addSuffixToDuplicates()

        for placeName in newArray {
            choiceCell = SDLChoiceCell(text: placeName, secondaryText: nil, tertiaryText: nil, voiceCommands: nil, artwork: nil, secondaryArtwork: nil)
            cells.append(choiceCell)
        }

        return cells
    }

    func present() {
        if cells.count == 0 {
            Alert.presentEmptySearchResultsAlert(searchTerm: searchText)
            return
        }

        let choiceSet = SDLChoiceSet(title: "Search Results", delegate: self, layout: .list, timeout: 30, initialPromptString: "Search Results", timeoutPromptString: "Search selection timed out", helpPromptString: nil, vrHelpList: nil, choices: cells)
        screenManager.present(choiceSet, mode: .manualOnly)
    }
}

extension MapItemsListInteraction: SDLChoiceSetDelegate {
    func choiceSet(_ choiceSet: SDLChoiceSet, didSelectChoice choice: SDLChoiceCell, withSource source: SDLTriggerSource, atRowIndex rowIndex: UInt) {
        let mapItem = mapItems[Int(rowIndex)]
        let dict: [String : MKMapItem] = ["mapItem": mapItem]
        NotificationCenter.default.post(name: .centerMapOnPlace, object: dict)
        guard let mapViewController = SDLViewControllers.map else {
            SDLLog.e("Error loading the SDL map view")
            return
        }
        ProxyManager.sharedManager.sdlManager.streamManager?.rootViewController = mapViewController
        mapViewController.setup()
    }

    func choiceSet(_ choiceSet: SDLChoiceSet, didReceiveError error: Error) {
        print("Error creating the search results menu: \(error.localizedDescription)")
    }
}
