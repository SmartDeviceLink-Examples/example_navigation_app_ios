//
//  MenuManager.swift
//  MobileNav
//
//  Created by James Lapinski on 5/14/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink

class MenuManager: NSObject {
    private let sdlManager: SDLManager

    init(with sdlManager:SDLManager) {
        self.sdlManager = sdlManager
        super.init()
    }

    func start() {
        loadMenuCells()
    }

    func loadMenuCells() {
        var cells: [SDLMenuCell] = []

        let searchCell = SDLMenuCell(title: "Search", icon: nil, voiceCommands: ["Search"]) { (source: SDLTriggerSource) in

        }
        cells.append(searchCell)

        let coffeeCell = SDLMenuCell(title: "Coffee Near Me", icon: nil, voiceCommands: ["Coffee Near Me", "Coffee"]) { (source: SDLTriggerSource) in
            
        }
        cells.append(coffeeCell)

        let restaurantsCell = SDLMenuCell(title: "Restaurants Near Me", icon: nil, voiceCommands: ["Restaurants Near Me", "Restaurants"]) { (source: SDLTriggerSource) in

        }
        cells.append(restaurantsCell)

        let gasStationsCell = SDLMenuCell(title: "Gas Stations Near Me", icon: nil, voiceCommands: ["Gas Stations Near Me", "Gas Stations"]) { (source: SDLTriggerSource) in

        }
        cells.append(gasStationsCell)
    }
}



