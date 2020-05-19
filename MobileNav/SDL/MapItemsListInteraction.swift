//
//  MapItemsListInteraction.swift
//  MobileNav
//
//  Created by James Lapinski on 5/19/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink
import MapKit

class MapItemsListInteraction: NSObject {
    private let cells: [SDLChoiceCell]
    private let screenManager: SDLScreenManager

    init(screenManager: SDLScreenManager, mapItems: [MKMapItem]) {
        self.cells = MapItemsListInteraction.createChoices(from: mapItems)
        self.screenManager = screenManager
    }

    private class func createChoices(from mapItems: [MKMapItem]) -> [SDLChoiceCell] {
        var cells = [SDLChoiceCell]()
        var choiceCell: SDLChoiceCell

        for item in mapItems {
            if item.name != nil {
                choiceCell = SDLChoiceCell(text: item.name!, secondaryText: item.description, tertiaryText: nil, voiceCommands: nil, artwork: nil, secondaryArtwork: nil)
                cells.append(choiceCell)
            } else {
                let choiceCell = SDLChoiceCell(text: item.description, secondaryText: nil, tertiaryText: nil, voiceCommands: nil, artwork: nil, secondaryArtwork: nil)
                cells.append(choiceCell)
            }
        }

        return cells
    }

    func present() {
        let choiceSet = SDLChoiceSet(title: "Search Results", delegate: self, layout: .list, timeout: 30, initialPromptString: "Search Results", timeoutPromptString: "Search selection timed out", helpPromptString: nil, vrHelpList: nil, choices: cells)
        screenManager.present(choiceSet, mode: .manualOnly)
    }

}

extension MapItemsListInteraction: SDLChoiceSetDelegate {
    func choiceSet(_ choiceSet: SDLChoiceSet, didSelectChoice choice: SDLChoiceCell, withSource source: SDLTriggerSource, atRowIndex rowIndex: UInt) {
        print(choice.text)
    }

    func choiceSet(_ choiceSet: SDLChoiceSet, didReceiveError error: Error) {
        print("Error creating the search results menu: \(error.localizedDescription)")
    }

}
