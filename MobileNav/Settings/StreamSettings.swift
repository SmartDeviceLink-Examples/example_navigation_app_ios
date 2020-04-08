//
//  StreamSettings.swift
//  MobileNav
//
//  Created by James Lapinski on 4/8/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import SmartDeviceLink

enum RenderType: String, CaseIterable {
    case layer = "Layer"
    case viewAfterScreenUpdates = "View After Screen Updates"
    case viewBeforeScreenUpdates = "View Before Screen Updates"
}

enum StreamType: String, CaseIterable {
    case onScreen = "On Screen"
    case offScreen = "Off Screen"
}
