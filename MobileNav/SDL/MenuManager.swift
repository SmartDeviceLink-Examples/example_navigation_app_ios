//
//  MenuManager.swift
//  MobileNav
//
//  Created by James Lapinski on 5/14/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import SmartDeviceLink
import UIKit

class MenuManager: NSObject {
    private let sdlManager: SDLManager
    private let searchManager = SearchManager()
    private var mapInteraction: MapItemsListInteraction?

    init(with sdlManager:SDLManager) {
        self.sdlManager = sdlManager
        super.init()
    }

    func start() {
        loadMenuCells()
    }

    func loadMenuCells() {
        var cells: [SDLMenuCell] = []

        let searchCell = SDLMenuCell(title: "Search", icon: nil, voiceCommands: nil) { (source: SDLTriggerSource) in
            let keyboard = KeyboardSearchInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager)
            keyboard.present()
        }
        cells.append(searchCell)

        let restaurantsCell = SDLMenuCell(title: "Restaurants Near Me", icon: nil, voiceCommands: nil) { (source: SDLTriggerSource) in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: "restaurants") { (mapItems, error) in
                    if error != nil {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    if let mapItems = mapItems {
                        self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, mapItems: mapItems)
                        self.mapInteraction?.present()
                    }
                }
            default:
                fatalError()
            }
        }
        cells.append(restaurantsCell)

        let coffeeCell = SDLMenuCell(title: "Coffee Near Me", icon: nil, voiceCommands: nil) { (source: SDLTriggerSource) in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: "coffee shops") { (mapItems, error) in
                    if error != nil {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    if let mapItems = mapItems {
                        self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, mapItems: mapItems)
                        self.mapInteraction?.present()
                    }
                }
            default:
                fatalError()
            }
        }
        cells.append(coffeeCell)

        let gasStationsCell = SDLMenuCell(title: "Gas Stations Near Me", icon: nil, voiceCommands: nil) { (source: SDLTriggerSource) in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: "gas stations") { (mapItems, error) in
                    if error != nil {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    if let mapItems = mapItems {
                        self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, mapItems: mapItems)
                        self.mapInteraction?.present()
                    }
                }
            default:
                fatalError()
            }
            
        }
        cells.append(gasStationsCell)
    }
}



