//
//  SDLMapViewTouchManager.swift
//  MobileNav
//
//  Created by Nicole on 6/17/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import SmartDeviceLink

enum SDLTouchType {
    case singleTap
    case doubleTap
    case panStarted
    case panMoved
    case panEnded
    case pinchStarted
    case pinchMoved
    case pinchEnded
}

typealias SDLTouchHandler = ((_ touchPoint: CGPoint, _ touchView: UIView?, _ touchScale: CGFloat?, _ touchType: SDLTouchType) -> Void)

class SDLMapViewTouchManager: NSObject, SDLTouchManagerDelegate {
    var mapTouchHandler: SDLTouchHandler?
    var menuButtonTouchHandler: SDLTouchHandler?

    init(sdlManager: SDLManager) {
        super.init()
        sdlManager.streamManager?.touchManager.touchEventDelegate = self
    }

    // MARK: - Tap

    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {
        if let view = view {
            switch view {
            case is UIButton:
                if view.isKind(of: SDLMenuButton.self) || view.isKind(of: MapButton.self) {
                    guard let touchHandler = mapTouchHandler else { return }
                    touchHandler(point, view, nil, .singleTap)
                }
            default: break
            }
        } else {
            guard let touchHandler = mapTouchHandler else { return }
            touchHandler(point, nil, nil, .singleTap)
        }
    }

    func touchManager(_ manager: SDLTouchManager, didReceiveDoubleTapFor view: UIView?, at point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, nil, .doubleTap)
    }

    // MARK: - Pan

    func touchManager(_ manager: SDLTouchManager, panningDidStartIn view: UIView?, at point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, nil, .panStarted)
    }

    func touchManager(_ manager: SDLTouchManager, didReceivePanningFrom fromPoint: CGPoint, to toPoint: CGPoint) {
        guard let touchHandler = mapTouchHandler else { return }
        let displacementPoint = fromPoint.displacement(toPoint: toPoint)
        touchHandler(displacementPoint, nil, nil, .panMoved)
    }

    func touchManager(_ manager: SDLTouchManager, panningDidEndIn view: UIView?, at point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, nil, .panEnded)
    }

    // MARK: - Pinch

    func touchManager(_ manager: SDLTouchManager, pinchDidStartIn view: UIView?, atCenter point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, view, nil, .pinchStarted)
    }

    func touchManager(_ manager: SDLTouchManager, didReceivePinchAtCenter point: CGPoint, withScale scale: CGFloat) {
        guard let touchHandler = mapTouchHandler else { return }
        touchHandler(point, nil, scale, .pinchMoved)
    }

    func touchManager(_ manager: SDLTouchManager, pinchDidEndIn view: UIView?, atCenter point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, view, nil, .pinchEnded)
    }
}

