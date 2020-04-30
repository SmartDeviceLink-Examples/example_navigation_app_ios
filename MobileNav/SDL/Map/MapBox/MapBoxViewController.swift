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
    @IBOutlet weak var centerMapButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    private var mapViewCenterPoint: CGPoint! = .zero
    private var newMapCenterPoint: CGPoint = .zero
    private var mapZoomLevel: Double = 0.0
    private let locationManager = CLLocationManager()
    var mapManager = MapManager()
    public private(set) var sdlMapViewTouchManager: SDLMapViewTouchManager?
    var mapTouchHandler: TouchHandler?
    var menuTouchHandler: TouchHandler?
    private var userLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
        setupTouchManager()
        setupButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
    }

    func setupTouchManager() {
        mapTouchHandler = mapManager.mapManagerTouchHandler
        menuTouchHandler = menuButton.buttonTouchHandler
        ProxyManager.sharedManager.sdlManager.streamManager?.touchManager.touchEventDelegate = self
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
                userLocation = location
            }
        } else {
            mapManager.setupMapView(with: mapView, userLocation: nil)
        }
    }

    func setupButtons() {
        // to do
        let searchImageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .medium)
        let searchImage = UIImage(systemName: "magnifyingglass", withConfiguration: searchImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        searchButton.setImage(searchImage, for: .normal)
        searchButton.layer.cornerRadius = searchButton.bounds.height/2
        searchButton.backgroundColor = .systemBlue

        let mapImageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let centerImage = UIImage(systemName: "location.circle", withConfiguration: mapImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        centerMapButton.setImage(centerImage, for: .normal)
        centerMapButton.layer.cornerRadius = centerMapButton.bounds.height/2
        centerMapButton.backgroundColor = .systemBlue

        let zoomInImage = UIImage(systemName: "plus.magnifyingglass", withConfiguration: mapImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        zoomInButton.setImage(zoomInImage, for: .normal)
        zoomInButton.layer.cornerRadius = zoomInButton.bounds.height/2
        zoomInButton.backgroundColor = .systemBlue

        let zoomOutImage = UIImage(systemName: "minus.magnifyingglass", withConfiguration: mapImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        zoomOutButton.setImage(zoomOutImage, for: .normal)
        zoomOutButton.layer.cornerRadius = zoomOutButton.bounds.height/2
        zoomOutButton.backgroundColor = .systemBlue

        let settingsImage = UIImage(systemName: "gear", withConfiguration: mapImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        settingsButton.setImage(settingsImage, for: .normal)
        settingsButton.layer.cornerRadius = settingsButton.bounds.height/2
        settingsButton.backgroundColor = .systemBlue
    }

    func presentKeyboard() {
        ProxyManager.sharedManager.sdlManager.screenManager.presentKeyboard(withInitialText: "Search for location", delegate: self)
    }
}

extension CGPoint {
    func displacement(toPoint: CGPoint) -> CGPoint {
        let xDisplacement = x - toPoint.x
        let yDisplacement = y - toPoint.y
        return CGPoint(x: xDisplacement, y: yDisplacement)
    }

    func scalePoint(_ scale: CGFloat) -> CGPoint {
        let xScale = x / scale
        let yScale = y / scale
        return CGPoint(x: xScale, y: yScale)
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

