//
//  SDLMenuTouchManager.swift
//  MobileNav
//
//  Created by James Lapinski on 4/19/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink

class SDLMenuTouchManager: NSObject, SDLTouchManagerDelegate {

    var menuTouchHandler: TouchHandler?

    init(menuTouchHandler: TouchHandler? = nil, sdlManager: SDLManager) {
        super.init()
        sdlManager.streamManager?.touchManager.touchEventDelegate = self

        self.menuTouchHandler = menuTouchHandler
    }

    // MARK: - Tap

    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {
        if let view = view {
            switch  view {
            case is UIButton:
                guard let touchHandler = menuTouchHandler else { return }
                touchHandler(point, nil, .singleTap)
            default: break
            }
        }
    }

}
