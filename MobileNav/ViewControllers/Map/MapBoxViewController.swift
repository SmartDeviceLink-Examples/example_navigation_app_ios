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
import MapKit

class MapBoxViewController: SDLCarWindowViewController {

    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var menuButton: SDLMenuButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var centerMapButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!

    @IBAction func searchButtonTapped(_ sender: UIButton) { performSearch() }
    @IBAction func zoomInButtonTapped(_ sender: UIButton) { mapManager.zoomIn() }
    @IBAction func zoomOutButtonTapped(_ sender: UIButton) { mapManager.zoomOut() }
    @IBAction func menuButtonTapped(_ sender: UIButton) { presentSettings() }
    @IBAction func centerLocationButtonTapped(_ sender: UIButton) {
        if let userLocation = userLocation {
            mapManager.centerLocation(lat: userLocation.coordinate.latitude, long: userLocation.coordinate.longitude)
        } else {
            let alert = UIAlertController(title: "Cant find user location", message: "Make sure you have location permissions enabled", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
        }
    }

    private var mapViewCenterPoint: CGPoint! = .zero
    private var newMapCenterPoint: CGPoint = .zero
    private var mapZoomLevel: Double = 0.0
    var mapManager = MapManager()
    private var annotation: MGLPointAnnotation?
    public private(set) var sdlMapViewTouchManager: SDLMapViewTouchManager?
    var mapTouchHandler: TouchHandler?
    var menuTouchHandler: TouchHandler?
    var userLocation: CLLocation?
    private var subscribedButtonsHidden = false
    var searchManager = SearchManager()
    var mapInteraction: MapItemsListInteraction?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(presentOffScreen), name: .offScreenConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUserLocation), name: .locationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSubscribedButtons), name: .hideSubscribedButtons, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showHiddenButtons), name: .showHiddenButtons, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(centerMapOnLocation), name: .sdl_centerMapOnPlace, object: nil)

        getUserLocation()
        setupTouchManager()
        setupButtons()

        if NotificationQueue.shared.lastNotification != nil {
            NotificationCenter.default.post(name: .sdl_centerMapOnPlace, object: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
    }
}

// MARK: - Helper Functions

extension MapBoxViewController {
    private func setupTouchManager() {
        mapTouchHandler = mapManager.mapManagerTouchHandler
        menuTouchHandler = menuButton.buttonTouchHandler
        ProxyManager.sharedManager.sdlManager.streamManager?.touchManager.touchEventDelegate = self
    }

    @objc func getUserLocation() {
        if let location = LocationManager.sharedManager.userLocation {
            mapView.showsUserLocation = true
            mapManager.setupMapView(with: mapView, location: location)
            userLocation = location
        } else {
            // Can't find user location, setting it to Detroit
            userLocation = CLLocation(latitude: 42.331429, longitude: -83.045753)
            mapManager.setupMapView(with: mapView, location: userLocation!)
        }
    }

    private func setupButtons() {
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        centerMapButton.setImage(UIImage(named: "center"), for: .normal)
        zoomInButton.setImage(UIImage(named: "zoom_in"), for: .normal)
        zoomOutButton.setImage(UIImage(named: "zoom_out"), for: .normal)

        // Hide buttons if we are going to subscribe them
        if let rpcVersion = ProxyManager.sharedManager.rpcVersion {
            if rpcVersion >= 6 {
                hideSubscribedButtons()
            }
        }
    }

    private func performSearch() {
        let storyboard = UIStoryboard.init(name: "Search", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "Search") as! SearchViewController
        searchVC.delegate = self
        present(searchVC, animated: true, completion: nil)
    }

    private func presentSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "Settings")
        settingsVC.navigationItem.title = "Settings"
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true, completion: nil)
    }

    @objc private func presentOffScreen() {
        let storyboard = UIStoryboard.init(name: "OffScreen", bundle: nil)
        let offScreenVC = storyboard.instantiateViewController(withIdentifier: "OffScreen") as! OffScreenViewController
        offScreenVC.modalPresentationStyle = .overFullScreen
        present(offScreenVC, animated: false, completion: nil)
    }

    @objc private func hideSubscribedButtons() {
        DispatchQueue.main.async {
            self.centerMapButton.isHidden = true
            self.zoomInButton.isHidden = true
            self.zoomOutButton.isHidden = true
            self.subscribedButtonsHidden = true
        }
    }

    @objc private func showHiddenButtons() {
        DispatchQueue.main.async {
            if self.subscribedButtonsHidden {
            self.centerMapButton.isHidden = false
            self.zoomInButton.isHidden = false
            self.zoomOutButton.isHidden = false
            self.subscribedButtonsHidden = false
        }
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
        mapManager.centerLocation(lat: annotation!.coordinate.latitude, long: annotation!.coordinate.longitude)
    }
}

extension MapBoxViewController {
    @objc func centerMapOnLocation(_ notification: Notification) {
        if let dict = notification.object as? [String: MKMapItem] {
            if let mapItem = dict["mapItem"] {
                if annotation != nil {
                    self.mapView.removeAnnotation(annotation!)
                }
                annotation = MGLPointAnnotation()
                annotation!.coordinate = mapItem.placemark.coordinate
                self.mapView.addAnnotation(annotation!)
                mapManager.centerLocation(lat: annotation!.coordinate.latitude, long: annotation!.coordinate.longitude)
            }
        }
    }
}


