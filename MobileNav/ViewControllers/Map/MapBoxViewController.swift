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

    @IBAction func searchButtonTapped(_ sender: UIButton) { performSearch() }
    @IBAction func zoomInButtonTapped(_ sender: UIButton) { zoomIn() }
    @IBAction func zoomOutButtonTapped(_ sender: UIButton) { zoomOut() }
    @IBAction func centerLocationButtonTapped(_ sender: UIButton) {
        centerLocation(lat: (userLocation!.coordinate.latitude), long: userLocation!.coordinate.longitude)
    }
    @IBAction func settingsButtonTapped(_ sender: UIButton) { presentSettings() }

    private var mapViewCenterPoint: CGPoint! = .zero
    private var newMapCenterPoint: CGPoint = .zero
    private var mapZoomLevel: Double = 0.0
    private let locationManager = CLLocationManager()
    var mapManager = MapManager()
    private var annotation: MGLPointAnnotation?
    public private(set) var sdlMapViewTouchManager: SDLMapViewTouchManager?
    var mapTouchHandler: TouchHandler?
    var menuTouchHandler: TouchHandler?
    var userLocation: CLLocation?

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

    func performSearch() {
        let storyboard = UIStoryboard.init(name: "Search", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "Search") as! SearchViewController
        searchVC.delegate = self
        present(searchVC, animated: true, completion: nil)
    }

    func zoomIn() {
        mapView.setZoomLevel(mapView.zoomLevel + 1, animated: true)
    }

    func zoomOut() {
        mapView.setZoomLevel(mapView.zoomLevel - 1, animated: true)
    }

    func centerLocation(lat:CLLocationDegrees, long:CLLocationDegrees) {
//        if let userLocation = userLocation {
//            self.mapView.setCenter(CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude), animated: false)
//        }
        self.mapView.setCenter(CLLocationCoordinate2DMake(lat, long), animated: false)
    }

    func presentSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "Settings")
        settingsVC.navigationItem.title = "Settings"
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true, completion: nil)
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

extension MapBoxViewController: SearchViewControllerDelegate {
    func didSelectPlace(coordinate: CLLocationCoordinate2D) {
        print("Latitude is \(coordinate.latitude), longitude is \(coordinate.longitude)")
        if annotation != nil {
            self.mapView.removeAnnotation(annotation!)
        }
        annotation = MGLPointAnnotation()
        annotation!.coordinate = coordinate
        self.mapView.addAnnotation(annotation!)
        self.centerLocation(lat: annotation!.coordinate.latitude, long: annotation!.coordinate.longitude)
    }
}


