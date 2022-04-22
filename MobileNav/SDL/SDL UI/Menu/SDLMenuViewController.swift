//
//  SDLMenuViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 4/15/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink

class SDLMenuViewController: SDLCarWindowViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var exitAppButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var restaurantsButton: UIButton!
    @IBOutlet weak var coffeeButton: UIButton!
    @IBOutlet weak var gasStationsButton: UIButton!
    private var searchManager = SearchManager()
    private var mapInteraction: MapItemsListInteraction?
    private var keyboard: KeyboardSearchInteraction?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
    }

    func setupTouchManager() {
        ProxyManager.sharedManager.sdlManager.streamManager?.touchManager.touchEventDelegate = self
    }

    func returnToMap() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .setMapAsRootViewController, object: nil)
        }
    }
}

// MARK: - SDLTouchManagerDelegate callbacks
extension SDLMenuViewController: SDLTouchManagerDelegate {
    /// Detect the user pan/scroll movement on the HMI screen in order to update the `SDLCarWindowViewController`'s view
    /// so it can update the screen position of the HMI menu
    func touchManager(_ manager: SDLTouchManager, didReceivePanningFrom fromPoint: CGPoint, to toPoint: CGPoint) {
        let displacementPoint = fromPoint.displacement(toPoint: toPoint)
        self.view.frame.origin.y += displacementPoint.y
    }

    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {
        if let view = view {
            switch view {
            case is UIButton:
                if backButton.frame.contains(point) {
                    returnToMap()
                }

                if searchButton.frame.contains(point) {
                    keyboard = KeyboardSearchInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager)
                    keyboard?.present()
                }

                if restaurantsButton.frame.contains(point) {
                    searchManager.searchFor(searchTerm: "restaurants") { (mapItems, error) in
                        guard error == nil else {
                            Alert.presentSearchErrorAlert()
                            return
                        }

                        if let mapItems = mapItems {
                            self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: "restaurants", mapItems: mapItems)
                            self.mapInteraction?.present()
                        }
                    }
                }

                if coffeeButton.frame.contains(point) {
                    searchManager.searchFor(searchTerm: "coffee shops") { (mapItems, error) in
                        guard error == nil else {
                            Alert.presentSearchErrorAlert()
                            return
                        }

                        if let mapItems = mapItems {
                            self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: "coffee shops", mapItems: mapItems)
                            self.mapInteraction?.present()
                        }
                    }
                }

                if gasStationsButton.frame.contains(point) {
                    searchManager.searchFor(searchTerm: "gas stations") { (mapItems, error) in
                        guard error == nil else {
                            Alert.presentSearchErrorAlert()
                            return
                        }

                        if let mapItems = mapItems {
                            self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, searchText: "gas stations", mapItems: mapItems)
                            self.mapInteraction?.present()
                        }
                    }
                }

                if exitAppButton.frame.contains(point) {
                    let closeRPC = SDLCloseApplication()
                    ProxyManager.sharedManager.sdlManager.send(closeRPC)
                }

            default: break
            }
        }
    }
}
