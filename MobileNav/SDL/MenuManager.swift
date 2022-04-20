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
    private var keyboard = KeyboardSearchInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager)

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

        let searchCell = SDLMenuCell(title: SDLMenuTitles.search, secondaryText: nil, tertiaryText: nil, icon: nil, secondaryArtwork: nil, voiceCommands: [SDLMenuTitles.search]) { [unowned self] source in
            guard self.isDriverDistracted == false else {
                Alert.presentDriverDistraction()
                return
            }

            self.keyboard.present()
        }
        cells.append(searchCell)

        let restaurantsCell = SDLMenuCell(title: SDLMenuTitles.restaurantsNearMe, secondaryText: nil, tertiaryText: nil, icon: nil, secondaryArtwork: nil, voiceCommands: [SDLMenuTitles.restaurantsNearMe]) { source in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: DefaultSearchTerms.restaurants) { (mapItems, error) in
                    guard error == nil else {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    guard let mapItems = mapItems else {
                        Alert.presentEmptySearchResultsAlert(searchTerm: DefaultSearchTerms.restaurants)
                        return
                    }

                    self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: DefaultSearchTerms.restaurants, mapItems: mapItems)
                    self.mapInteraction?.present()
                }
            default:
                fatalError()
            }
        }
        cells.append(restaurantsCell)

        let coffeeCell = SDLMenuCell(title: SDLMenuTitles.coffeeNearMe, secondaryText: nil, tertiaryText: nil, icon: nil, secondaryArtwork: nil, voiceCommands: [SDLMenuTitles.coffeeNearMe]) { source in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: DefaultSearchTerms.coffeeShops) { (mapItems, error) in
                    guard error == nil else {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    guard let mapItems = mapItems else {
                        Alert.presentEmptySearchResultsAlert(searchTerm: DefaultSearchTerms.coffeeShops)
                        return
                    }

                    self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: DefaultSearchTerms.coffeeShops, mapItems: mapItems)
                    self.mapInteraction?.present()
                }
            default:
                fatalError()
            }
        }
        cells.append(coffeeCell)

        let gasStationsCell = SDLMenuCell(title: SDLMenuTitles.gasNearMe, secondaryText: nil, tertiaryText: nil, icon: nil, secondaryArtwork: nil, voiceCommands: [SDLMenuTitles.gasNearMe]) { source in
            switch source {
            case .menu:
                self.searchManager.searchFor(searchTerm: DefaultSearchTerms.gasStations) { (mapItems, error) in
                    guard error == nil else {
                        Alert.presentSearchErrorAlert()
                        return
                    }

                    guard let mapItems = mapItems else {
                        Alert.presentEmptySearchResultsAlert(searchTerm: DefaultSearchTerms.gasStations)
                        return
                    }

                    self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: DefaultSearchTerms.gasStations, mapItems: mapItems)
                    self.mapInteraction?.present()
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
