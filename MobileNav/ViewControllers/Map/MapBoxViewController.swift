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
        if let userLocation = userLocation {
            centerLocation(lat: userLocation.coordinate.latitude, long: userLocation.coordinate.longitude)
        } else {
            let alert = UIAlertController(title: "Cant find user location", message: "Make sure you have location permissions enabled", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
        }
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

        NotificationCenter.default.addObserver(self, selector: #selector(presentOffScreen), name: .offScreenConnected, object: nil)

        getUserLocation()
        setupTouchManager()
        setupButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
    }
}

// MARK: - Helper Functions

extension MapBoxViewController {
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
        let searchImageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .medium)
        let searchImage = UIImage(systemName: "magnifyingglass", withConfiguration: searchImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        searchButton.setImage(searchImage, for: .normal)

        let mapImageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let centerImage = UIImage(systemName: "location.circle", withConfiguration: mapImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        centerMapButton.setImage(centerImage, for: .normal)

        let zoomInImage = UIImage(systemName: "plus.magnifyingglass", withConfiguration: mapImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        zoomInButton.setImage(zoomInImage, for: .normal)

        let zoomOutImage = UIImage(systemName: "minus.magnifyingglass", withConfiguration: mapImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        zoomOutButton.setImage(zoomOutImage, for: .normal)

        let settingsImage = UIImage(systemName: "gear", withConfiguration: mapImageConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        settingsButton.setImage(settingsImage, for: .normal)
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
        self.mapView.setCenter(CLLocationCoordinate2DMake(lat, long), animated: false)
    }

    func presentSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "Settings")
        settingsVC.navigationItem.title = "Settings"
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true, completion: nil)
    }

    @objc func presentOffScreen() {
        let storyboard = UIStoryboard.init(name: "OffScreen", bundle: nil)
        let offScreenVC = storyboard.instantiateViewController(withIdentifier: "OffScreen") as! OffScreenViewController
        offScreenVC.modalPresentationStyle = .overFullScreen
        present(offScreenVC, animated: true, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate

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

// MARK: - SearchViewControllerDelegate

extension MapBoxViewController: SearchViewControllerDelegate {
    func didSelectPlace(coordinate: CLLocationCoordinate2D) {
        if annotation != nil {
            self.mapView.removeAnnotation(annotation!)
        }
        annotation = MGLPointAnnotation()
        annotation!.coordinate = coordinate
        self.mapView.addAnnotation(annotation!)
        self.centerLocation(lat: annotation!.coordinate.latitude, long: annotation!.coordinate.longitude)
    }
}


