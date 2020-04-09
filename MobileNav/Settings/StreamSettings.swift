//
//  StreamSettings.swift
//  MobileNav
//
//  Created by James Lapinski on 4/8/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import SmartDeviceLink

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case render
    case stream

    var description: String {
        switch self {
        case .render: return "Render Type"
        case .stream: return "Stream Type"
        }
    }
}

enum RenderType: Int, CaseIterable, CustomStringConvertible {
    case layer
    case viewAfterScreenUpdates
    case viewBeforeScreenUpdates

    var description: String {
        switch self {
        case .layer: return "Layer"
        case .viewAfterScreenUpdates: return "View After Screen Updates"
        case .viewBeforeScreenUpdates: return "View Before Screen Updates"
        }
    }
}

enum StreamType: Int, CaseIterable, CustomStringConvertible {
    case onScreen
    case offScreen

    var description: String {
        switch self {
        case .onScreen: return "On Screen"
        case .offScreen: return "Off Screen"
        }
    }
}

class StreamSettings: NSObject {

    let carWindowRenderType: SDLCarWindowRenderingType
    let isOffScreen: Bool

    init(renderType: SDLCarWindowRenderingType, isOffScreen: Bool) {
        self.carWindowRenderType = renderType
        self.isOffScreen = isOffScreen
        super.init()
    }
}
