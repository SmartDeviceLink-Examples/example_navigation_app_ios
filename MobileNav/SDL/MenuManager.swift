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
    private var isDriverDistracted = false

    init(with sdlManager:SDLManager) {
        self.sdlManager = sdlManager
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(driverDistractionDidChange(_:)), name: .SDLDidChangeDriverDistractionState, object: nil)
    }

    func start() {
        loadMenuCells()
    }

    func loadMenuCells() {
        var cells: [SDLMenuCell] = []

        let searchCell = SDLMenuCell(title: SDLMenuTitles.search, icon: nil, voiceCommands: [SDLMenuTitles.search]) { (source: SDLTriggerSource) in
            if self.isDriverDistracted {
                Alert.presentDriverDistraction()
                return
            }

            let keyboard = KeyboardSearchInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager)
            keyboard.present()
        }
        cells.append(searchCell)

        let restaurantsCell = SDLMenuCell(title: SDLMenuTitles.restaurantsNearMe, icon: nil, voiceCommands: [SDLMenuTitles.restaurantsNearMe]) { (source: SDLTriggerSource) in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: "restaurants") { (mapItems, error) in
                    if error != nil {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    if let mapItems = mapItems {
                        self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: "restaurants", mapItems: mapItems)
                        self.mapInteraction?.present()
                    }
                }
            default:
                fatalError()
            }
        }
        cells.append(restaurantsCell)

        let coffeeCell = SDLMenuCell(title: SDLMenuTitles.coffeeNearMe, icon: nil, voiceCommands: [SDLMenuTitles.coffeeNearMe]) { (source: SDLTriggerSource) in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: "coffee shops") { (mapItems, error) in
                    if error != nil {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    if let mapItems = mapItems {
                        self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: "coffee shops", mapItems: mapItems)
                        self.mapInteraction?.present()
                    }
                }
            default:
                fatalError()
            }
        }
        cells.append(coffeeCell)

        let gasStationsCell = SDLMenuCell(title: SDLMenuTitles.gasNearMe, icon: nil, voiceCommands: [SDLMenuTitles.gasNearMe]) { (source: SDLTriggerSource) in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: "gas stations") { (mapItems, error) in
                    if error != nil {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    if let mapItems = mapItems {
                        self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: "gas stations", mapItems: mapItems)
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

// MARK: - Driver Distraction Status

private extension MenuManager {
    @objc func driverDistractionDidChange(_ notification: SDLRPCNotificationNotification) {
        guard let driverDistraction = notification.notification as? SDLOnDriverDistraction else { return }
        isDriverDistracted = (driverDistraction.state == .on)
    }
}
