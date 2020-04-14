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
    private var mapView: MGLMapView! {
        didSet{
            mapViewCenterPoint = mapView.center
        }
    }

    private var mapViewCenterPoint: CGPoint! = .zero
    private var newMapCenterPoint: CGPoint = .zero
    private var mapZoomLevel: Double = 0.0

    func setupMapView(with mapView: MGLMapView, userLocation:CLLocation?) {
        self.mapView = mapView

        mapView.scaleBar.isHidden = false
        mapView.compassView.isHidden = false

        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false

        var latitude = 42.331429
        var longitude = -83.045753

        if let userLocation = userLocation {
            latitude = userLocation.coordinate.latitude
            longitude = userLocation.coordinate.longitude
        }

        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        mapView.setCenter(coordinate, zoomLevel: 12, animated: false)

        newMapCenterPoint = mapView.center
        mapZoomLevel = mapView.zoomLevel
    }

    private func updateScreen() {
        let mapCenterPoint = self.mapViewCenterPoint
        let newMapCenterPoint = self.newMapCenterPoint
        guard mapCenterPoint != newMapCenterPoint else { return }

        DispatchQueue.main.async { [unowned self] in
            // Set new center
            let newMapCenterCoordinate = self.mapView.convert(newMapCenterPoint, toCoordinateFrom: nil)
            self.mapView.setCenter(newMapCenterCoordinate, animated: false)
            self.newMapCenterPoint = self.mapView.center
        };
    }
}

extension MapManager {
    var mapManagerTouchHandler: TouchHandler? {
        return { [unowned self] (touchPoint: CGPoint, scale: CGFloat?, touchType: TouchType) in
            switch touchType {
            case .singleTap:
                self.zoom(to: touchPoint)
            case .doubleTap:
                self.zoom(out: touchPoint)
            case .panMoved:
                self.panMoved(displacement: touchPoint)
            case .pinchMoved:
                self.pinchMoved(centerPoint: touchPoint, scale: scale ?? 1.0)
            case .panStarted, .pinchStarted: break
            case .panEnded, .pinchEnded: break
            }
            self.updateScreen()
        }
    }

    /// Zooms-in and centers around the tap gesture point.
    ///
    /// - Parameters:
    ///   - touchPoint: The location of the tap on the screen
    private func zoom(to touchPoint: CGPoint) {
        newMapCenterPoint = touchPoint
        let newZoomLevel = mapView.zoomLevel + 1
        mapZoomLevel = newZoomLevel
    }

    /// Zooms-out and centers around the tap gesture point.
    ///
    /// - Parameters:
    ///   - touchPoint: The location of the tap on the screen
    private func zoom(out touchPoint: CGPoint) {
        newMapCenterPoint = touchPoint
        let newZoomLevel = mapView.zoomLevel - 1
        mapZoomLevel = newZoomLevel
    }

    /// Pans the map.
    ///
    /// - Parameter displacement: The distance the of the finger drag
    private func panMoved(displacement: CGPoint) {
        newMapCenterPoint = CGPoint(
            x: newMapCenterPoint.x + displacement.x,
            y: newMapCenterPoint.y + displacement.y)
    }

    /// A very pinch algorithm that zooms around the current center of the map.
    ///
    /// - Parameters:
    ///   - centerPoint: The center point of the pinch gesture
    ///   - scale: The pinch gesture scale. Pinching in returns a scale < 1; pinching out returns a scale > 0
    private func pinchMoved(centerPoint: CGPoint, scale: CGFloat) {
        let zoomAmount = 1.0 / 10.0
        mapZoomLevel = scale < 1 ? mapZoomLevel - zoomAmount : mapZoomLevel + zoomAmount
    }
}
