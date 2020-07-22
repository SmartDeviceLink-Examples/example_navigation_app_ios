//
//  SDLAppConstants.swift
//  MobileNav
//
//  Created by James Lapinski on 4/3/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit

struct SDLAppConstants {
    static let connectionType = ConnectionType.iap
    static let appName = SecretValues.appName() ?? ""
    static let appId = SecretValues.appID() ?? ""
    static let ipAddress = "192.168.1.36"
    static let port: UInt16 = 12345
}

struct SDLViewControllers {
    static let map = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? MapBoxViewController
    static let menu = UIStoryboard(name: "SDLMenu", bundle: nil).instantiateInitialViewController() as? SDLMenuViewController
}

struct SDLMenuTitles {
    static let search = "Search"
    static let coffeeNearMe = "Coffee Near Me"
    static let restaurantsNearMe = "Restaurants Near Me"
    static let gasNearMe = "Gas Stations Near Me"
}

struct DefaultSearchTerms {
    static let restaurants = "restaurants"
    static let coffeeShops = "coffee shops"
    static let gasStations = "gas stations"
}
