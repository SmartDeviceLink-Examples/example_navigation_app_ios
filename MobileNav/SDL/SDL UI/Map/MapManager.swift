//
//  MapManager.swift
//  MobileNav
//
//  Created by James Lapinski on 4/14/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import Mapbox
import SmartDeviceLink


class MapManager: NSObject {
    private var mapView: MGLMapView!
    private var locationManager: LocationManager?
    private var annotation: MGLPointAnnotation?
    private var keyboard: KeyboardSearchInteraction?

    func setupMapView(with mapView: MGLMapView, locationManager: LocationManager) {
        self.locationManager = locationManager
        locationManager.userLocationUpdatedHandler = userLocationUpdatedHandler
        
        self.mapView = mapView
        mapView.showsUserLocation = true
        mapView.scaleBar.isHidden = true
        mapView.compassView.isHidden = false
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false

        if let userLocation = locationManager.userLocation {
            let userLocationCoordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
            mapView.setCenter(userLocationCoordinate, zoomLevel: 12, animated: false)
        }
    }

    func setNewAnnotation(at coordinate: CLLocationCoordinate2D) {
        if annotation != nil {
            self.mapView.removeAnnotation(annotation!)
        }
        annotation = MGLPointAnnotation()
        annotation!.coordinate = coordinate
        self.mapView.addAnnotation(annotation!)
        centerLocation(lat: coordinate.latitude, long: coordinate.longitude)
    }

    func zoomIn() {
        mapView.setZoomLevel(mapView.zoomLevel + 1, animated: true)
    }

    func zoomOut() {
        mapView.setZoomLevel(mapView.zoomLevel - 1, animated: true)
    }

    func centerLocation() -> Bool {
        if let userLocation = locationManager?.userLocation {
            let userLocationCoordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
            mapView.setCenter(userLocationCoordinate, zoomLevel: 12, animated: false)
            return true
        }

        return false
    }

    private func centerLocation(lat:CLLocationDegrees, long:CLLocationDegrees) {
        self.mapView.setCenter(CLLocationCoordinate2DMake(lat, long), animated: false)
    }

    private var userLocationUpdatedHandler: ((CLLocation) -> Void) {
        return { [weak self] location in
            self?.centerLocation(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        }
    }
}

extension MapManager {
    var touchHandler: SDLTouchHandler? {
        return { [unowned self] (touchPoint: CGPoint, touchView: UIView?, scale: CGFloat?, touchType: SDLTouchType) in
            switch touchType {
            case .singleTap:
                if touchView == nil {
                    self.zoom(to: touchPoint)
                } else {
                    switch touchView?.tag {
                    case MapButtonState.search.tag:
                        self.presentKeyboard()
                    case MapButtonState.center.tag:
                        _ = self.centerLocation()
                    case MapButtonState.zoomIn.tag:
                        self.zoomIn()
                    case MapButtonState.zoomOut.tag:
                        self.zoomOut()
                    case MapButtonState.menu.tag:
                        self.presentMenu()
                    default: break
                    }
                }
            case .doubleTap:
                self.zoom(out: touchPoint)
            case .panMoved:
                self.panMoved(displacement: touchPoint)
            case .pinchMoved:
                self.pinchMoved(centerPoint: touchPoint, scale: scale ?? 1.0)
            case .pinchStarted, .pinchEnded, .panStarted, .panEnded: break
            }
        }
    }

    /// Zooms-in and centers around the tap gesture point.
    ///
    /// - Parameters:
    ///   - touchPoint: The location of the tap on the screen
    private func zoom(to touchPoint: CGPoint) {
        let newMapCenterCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        mapView.setCenter(newMapCenterCoordinate, zoomLevel: mapView.zoomLevel + 1, animated: true)
    }

    /// Zooms-out and centers around the tap gesture point.
    ///
    /// - Parameters:
    ///   - touchPoint: The location of the tap on the screen
    private func zoom(out touchPoint: CGPoint) {
        let newMapCenterCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        mapView.setCenter(newMapCenterCoordinate, zoomLevel: mapView.zoomLevel - 1, animated: true)
    }

    /// Pans the map.
    ///
    /// - Parameter displacement: The distance the of the finger drag
    private func panMoved(displacement: CGPoint) {
        let centerScreenPoint: CGPoint = mapView.convert(mapView.centerCoordinate, toPointTo: nil)
        let tapPoint = CGPoint(x: centerScreenPoint.x + displacement.x, y: centerScreenPoint.y + displacement.y)
        let tapCoordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: nil)
        mapView.setCenter(tapCoordinate, zoomLevel: mapView.zoomLevel, animated: false)
    }

    /// A pinch algorithm that zooms around the current center of the map.
    ///
    /// - Parameters:
    ///   - centerPoint: The center point of the pinch gesture
    ///   - scale: The pinch gesture scale. Pinching in returns a scale < 1; pinching out returns a scale > 0
    private func pinchMoved(centerPoint: CGPoint, scale: CGFloat) {
        let zoomAmount = 0.5
        let currentMapZoomLevel = mapView.zoomLevel
        let newMapZoomLevel = scale < 1 ? (currentMapZoomLevel - zoomAmount) : (currentMapZoomLevel + zoomAmount)
        mapView.setZoomLevel(newMapZoomLevel, animated: false)
    }
}

extension MapManager {
    /// Presents a keyboard
    func presentKeyboard() {
        keyboard = KeyboardSearchInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager)
        keyboard?.present()
    }
    /// Presents a search menu
    private func presentMenu() {
        guard let menuViewController = SDLViewControllers.menu else {
            SDLLog.e("Error loading the SDL menu view controller")
            return
        }

        if ProxyManager.isOffScreenStreaming {
            ProxyManager.sharedManager.sdlManager.streamManager?.rootViewController = menuViewController
            menuViewController.setupTouchManager()
        } else {
            for window in UIApplication.shared.windows {
                if (!(window.rootViewController?.isKind(of: MapBoxViewController.self) ?? false)) { continue }
                window.rootViewController = menuViewController
                menuViewController.setupTouchManager()
                ProxyManager.sharedManager.sdlManager.streamManager?.rootViewController = window.rootViewController
                break
            }
        }
    }
}
