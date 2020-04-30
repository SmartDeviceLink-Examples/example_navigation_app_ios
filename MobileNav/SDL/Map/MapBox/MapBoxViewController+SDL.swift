//
//  MapBoxViewController+SDL.swift
//  MobileNav
//
//  Created by James Lapinski on 4/30/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import SmartDeviceLink

extension MapBoxViewController: SDLKeyboardDelegate {
    func userDidSubmitInput(_ inputText: String, withEvent source: SDLKeyboardEvent) {
        let searchManager = SearchManager()
        switch source {
        case .voice:
            searchManager.getSearchResults(from: inputText)
        case .submitted:
            searchManager.getSearchResults(from: inputText)
        default: break
        }
    }

    func keyboardDidAbort(withReason event: SDLKeyboardEvent) {
        print("Keyboard was aborted")
    }
}

extension MapBoxViewController: SDLTouchManagerDelegate {
    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {
        if let view = view {
            switch view {
            case is UIButton:
                if menuButton.frame.contains(point) {
                    guard let touchHandler = menuTouchHandler else { return }
                    touchHandler(point, nil, .singleTap)
                }

                if searchButton.frame.contains(point) { presentKeyboard() }

                if zoomInButton.frame.contains(point) {
                    mapView.setZoomLevel(mapView.zoomLevel + 1, animated: true)
                    mapManager.updateScreen()
                }

                if zoomOutButton.frame.contains(point) {
                    mapView.setZoomLevel(mapView.zoomLevel - 1, animated: true)
                    mapManager.updateScreen()
                }

                if centerMapButton.frame.contains(point) {
                    // to do
                }

            default:break
            }
        } else {
            guard let touchHandler = mapTouchHandler else { return }
            touchHandler(point, nil, .singleTap)
        }
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
