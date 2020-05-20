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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTouchManager()
    }

    func setupTouchManager() {
        ProxyManager.sharedManager.sdlManager.streamManager?.touchManager.touchEventDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
    }

    func returnToMap() {
        let mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? MapBoxViewController
        ProxyManager.sharedManager.sdlManager.streamManager?.rootViewController = mapVC
    }
}

extension SDLMenuViewController: SDLTouchManagerDelegate {
    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {
        if let view = view {
            switch view {
            case is UIButton:
                if backButton.frame.contains(point) {
                    returnToMap()
                }

                if searchButton.frame.contains(point) {
                    let keyboard = KeyboardSearchInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager)
                    keyboard.present()
                }

                if restaurantsButton.frame.contains(point) {
                    searchManager.searchFor(searchTerm: "restaurants") { (mapItems, error) in
                        if error != nil {
                            Alert.presentSearchErrorAlert()
                            return
                        }

                        if let mapItems = mapItems {
                            self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, mapItems: mapItems)
                            self.mapInteraction?.present()
                        }
                    }
                }

                if coffeeButton.frame.contains(point) {
                    searchManager.searchFor(searchTerm: "coffee shops") { (mapItems, error) in
                        if error != nil {
                            Alert.presentSearchErrorAlert()
                            return
                        }

                        if let mapItems = mapItems {
                            self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, mapItems: mapItems)
                            self.mapInteraction?.present()
                        }
                    }
                }

                if gasStationsButton.frame.contains(point) {
                    searchManager.searchFor(searchTerm: "gas stations") { (mapItems, error) in
                        if error != nil {
                            Alert.presentSearchErrorAlert()
                            return
                        }

                        if let mapItems = mapItems {
                            self.mapInteraction = MapItemsListInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager, mapItems: mapItems)
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
