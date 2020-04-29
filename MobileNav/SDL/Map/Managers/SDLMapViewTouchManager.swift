//
//  SDLMapViewTouchManager.swift
//  MobileNav
//
//  Created by James Lapinski on 4/14/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink

enum TouchType {
    case singleTap
    case doubleTap
    case panStarted
    case panMoved
    case panEnded
    case pinchStarted
    case pinchMoved
    case pinchEnded
}

typealias TouchHandler = ((_ touchPoint: CGPoint, _ touchScale: CGFloat?, _ touchType: TouchType) -> Void)

class SDLMapViewTouchManager: NSObject, SDLTouchManagerDelegate {
    var mapTouchHandler: TouchHandler?

    init(mapTouchHandler: TouchHandler? = nil, sdlManager: SDLManager) {
        super.init()
        sdlManager.streamManager?.touchManager.touchEventDelegate = self

        self.mapTouchHandler = mapTouchHandler
    }

    // MARK: - Tap

    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {

        guard let touchHandler = mapTouchHandler else { return }
        touchHandler(point, nil, .singleTap)
    }

    func touchManager(_ manager: SDLTouchManager, didReceiveDoubleTapFor view: UIView?, at point: CGPoint) {
        // Double tap will be disabled if the `tapTimeThreshold` is set to 0
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .doubleTap)
    }

    // MARK: - Pan

    func touchManager(_ manager: SDLTouchManager, panningDidStartIn view: UIView?, at point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .panStarted)
    }

    func touchManager(_ manager: SDLTouchManager, didReceivePanningFrom fromPoint: CGPoint, to toPoint: CGPoint) {
        guard let touchHandler = mapTouchHandler else { return }
        let displacementPoint = fromPoint.displacement(toPoint: toPoint)
        touchHandler(displacementPoint, nil, .panMoved)
    }

    func touchManager(_ manager: SDLTouchManager, panningDidEndIn view: UIView?, at point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .panEnded)
    }

    // MARK: - Pinch

    func touchManager(_ manager: SDLTouchManager, pinchDidStartIn view: UIView?, atCenter point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .pinchStarted)
    }

    func touchManager(_ manager: SDLTouchManager, didReceivePinchAtCenter point: CGPoint, withScale scale: CGFloat) {
        guard let touchHandler = mapTouchHandler else { return }
        touchHandler(point, scale, .pinchMoved)
    }

    func touchManager(_ manager: SDLTouchManager, pinchDidEndIn view: UIView?, atCenter point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .pinchEnded)
    }
}
