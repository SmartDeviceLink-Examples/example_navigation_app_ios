//
//  MapBoxViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 4/7/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink
import Mapbox

class MapBoxViewController: SDLCarWindowViewController {

    @IBOutlet var mapView: MGLMapView!

    private var mapViewCenterPoint: CGPoint! = .zero
    private var newMapCenterPoint: CGPoint = .zero
    private var mapZoomLevel: Double = 0.0
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
    }

    func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            if let location = locationManager.location {
                mapView.showsUserLocation = true
                setupMapView(with: location)
            }
        } else {
            setupMapView(with: nil)
        }
    }

    func setupMapView(with userLocation:CLLocation?) {
        mapView.scaleBar.isHidden = false
        mapView.compassView.isHidden = false

        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false

        var latitude = 0.0
        var longitude = 0.0

        if let userLocation = userLocation {
            latitude = userLocation.coordinate.latitude
            longitude = userLocation.coordinate.longitude
        } else {
            latitude = 42.331429
            longitude = -83.045753
        }

        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        mapView.setCenter(coordinate, zoomLevel: 12, animated: false)

        newMapCenterPoint = mapView.center
        mapZoomLevel = mapView.zoomLevel
    }
}

extension MapBoxViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            getUserLocation()
        case .denied:
            print("Cannot access user location, permission was denied by user.")
        default:
            setupMapView(with: nil)
        }
    }

}
