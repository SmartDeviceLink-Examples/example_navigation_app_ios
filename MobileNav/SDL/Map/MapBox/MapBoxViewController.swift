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

    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var menuButton: SDLMenuButton!
    @IBOutlet weak var searchButton: UIButton!

    private var mapViewCenterPoint: CGPoint! = .zero
    private var newMapCenterPoint: CGPoint = .zero
    private var mapZoomLevel: Double = 0.0
    private let locationManager = CLLocationManager()
    private var mapManager = MapManager()
    public private(set) var sdlMapViewTouchManager: SDLMapViewTouchManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
        setupTouchManager()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large)
        let searchImage = UIImage(systemName: "magnifyingglass.circle.fill", withConfiguration: imageConfig)
        searchButton.setImage(searchImage, for: .normal)
        searchButton.layer.cornerRadius = searchButton.bounds.height/2
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
    }

    func setupTouchManager() {
        sdlMapViewTouchManager = SDLMapViewTouchManager(mapTouchHandler: mapManager.mapManagerTouchHandler, menuButtonTouchHandler: menuButton.buttonTouchHandler, sdlManager: ProxyManager.sharedManager.sdlManager)
    }

    func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            if let location = locationManager.location {
                mapView.showsUserLocation = true
                mapManager.setupMapView(with: mapView, userLocation: location)
            }
        } else {
            mapManager.setupMapView(with: mapView, userLocation: nil)
        }
    }
}

extension MapBoxViewController: SDLTouchManagerDelegate {
    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {
        <#code#>
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
            break
        }
    }

}

