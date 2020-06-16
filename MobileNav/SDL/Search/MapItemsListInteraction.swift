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

        for item in mapItems {
            if item.name == nil { continue }

            choiceCell = SDLChoiceCell(text: item.name!, secondaryText: nil, tertiaryText: nil, voiceCommands: nil, artwork: nil, secondaryArtwork: nil)
            cells.append(choiceCell)
        }

        return cells
    }

    func present() {
        guard cells.count > 0 else {
            Alert.presentEmptySearchResultsAlert(searchTerm: searchText)
            return
        }

        let fixedDuplicateCells = fixDuplicates(cells: cells)

        let choiceSet = SDLChoiceSet(title: "Search Results", delegate: self, layout: .list, timeout: 30, initialPromptString: "Search Results", timeoutPromptString: "Search selection timed out", helpPromptString: nil, vrHelpList: nil, choices: fixedDuplicateCells)
        screenManager.present(choiceSet, mode: .manualOnly)
    }

    private func fixDuplicates(cells: [SDLChoiceCell]) -> [SDLChoiceCell] {
        var duplicateCount: [String: Int] = [:]
        var newCells: [SDLChoiceCell] = []
        cells.forEach { (cell: SDLChoiceCell) in
            let newCell: SDLChoiceCell
            if duplicateCount[cell.text] == nil {
                duplicateCount[cell.text] = 1
                newCell = cell
            } else {
                let newText = "\(cell.text) (\(duplicateCount[cell.text]!))"
                newCell = SDLChoiceCell(text: newText, secondaryText: cell.secondaryText, tertiaryText: cell.tertiaryText, voiceCommands: cell.voiceCommands, artwork: cell.artwork, secondaryArtwork: cell.secondaryArtwork)
                duplicateCount[cell.text] = duplicateCount[cell.text]! + 1
            }

            newCells.append(newCell)
        }

        return newCells
    }
}

extension MapItemsListInteraction: SDLChoiceSetDelegate {
    func choiceSet(_ choiceSet: SDLChoiceSet, didSelectChoice choice: SDLChoiceCell, withSource source: SDLTriggerSource, atRowIndex rowIndex: UInt) {
        let mapItem = mapItems[Int(rowIndex)]
        let dict: [String : MKMapItem] = ["mapItem": mapItem]

        DispatchQueue.main.async {
            if ProxyManager.isOffScreenStreaming {
                NotificationCenter.default.post(Notification(name: .setMapAsRootViewController))
            } else {
                guard let mapViewController = SDLViewControllers.map else {
                    SDLLog.e("Error loading the SDL menu view controller")
                    return
                }
                for window in UIApplication.shared.windows {
                    if (!(window.rootViewController?.isKind(of: SDLMenuViewController.self) ?? false)) { continue }
                    window.rootViewController = mapViewController
                    NotificationCenter.default.post(Notification(name: .setMapAsRootViewController))
                    mapViewController.setup()
                    break
                }
            }
        }

        NotificationCenter.default.post(name: .centerMapOnPlace, object: dict)
    }

    func choiceSet(_ choiceSet: SDLChoiceSet, didReceiveError error: Error) {
        print("Error creating the search results menu: \(error.localizedDescription)")
    }
}
