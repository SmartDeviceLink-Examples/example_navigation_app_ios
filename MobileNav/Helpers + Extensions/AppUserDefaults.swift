//
//  AppUserDefaults.swift
//  MobileNav
//
//  Created by James Lapinski on 5/18/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation

class AppUserDefaults {
    struct Keys {
        static let renderType = "renderType"
        static let streamType = "isOffScreen"
    }

    static let shared = AppUserDefaults()
    static func setDefaults() {
        var defaults: [String: Any] = [:]
        defaults[Keys.renderType] = RenderType.viewAfterScreenUpdates.rawValue
        defaults[Keys.streamType] = StreamType.offScreen.rawValue
        UserDefaults.standard.register(defaults: defaults)
    }

    var renderType: RenderType? {
        get {
            return RenderType(rawValue: UserDefaults.standard.integer(forKey: Keys.renderType))
        }
        set {
            UserDefaults.standard.set(newValue!.rawValue, forKey: Keys.renderType)
        }
    }

    var streamType: StreamType? {
        get {
            return StreamType(rawValue: UserDefaults.standard.integer(forKey: Keys.streamType))
        }
        set {
            UserDefaults.standard.set(newValue!.rawValue, forKey: Keys.streamType)
        }
    }
}
