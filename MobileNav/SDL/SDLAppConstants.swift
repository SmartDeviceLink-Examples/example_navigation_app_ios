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
    static let appName = ""
    static let appId = ""
    static let ipAddress = ""
    static let port: UInt16 = 12345
}

struct SDLViewControllers {
    static let map = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? MapBoxViewController
    static let menu = UIStoryboard(name: "SDLMenu", bundle: nil).instantiateInitialViewController() as? SDLMenuViewController
}
