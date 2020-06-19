//
//  MapBoxViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 4/7/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Mapbox
import MapKit
import SmartDeviceLink
import UIKit

class MapBoxViewController: SDLCarWindowViewController {
    private var mapManager = MapManager()
    private var locationManager: LocationManager?

    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var menuButton: SDLMenuButton!
    @IBOutlet weak var searchButton: MapButton!
    @IBOutlet weak var centerMapButton: MapButton!
    @IBOutlet weak var zoomOutButton: MapButton!
    @IBOutlet weak var zoomInButton: MapButton!

    // SDL App
    private var sdlTouchHandler: SDLTouchHandler?
    private var sdlMapViewTouchManager: SDLMapViewTouchManager?

    func setupLocationManager(_ locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    func setupSDLApp() {
        self.sdlMapViewTouchManager = SDLMapViewTouchManager(sdlManager: ProxyManager.sharedManager.sdlManager)
        sdlMapViewTouchManager?.mapTouchHandler = mapManager.touchHandler

        NotificationCenter.default.addObserver(self, selector: #selector(setAsRootViewController), name: .setMapAsRootViewController, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapButtons()
        setupMapManager()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard sdlMapViewTouchManager != nil else { return }
        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
    }
}

// MARK: - Button Actions

extension MapBoxViewController {
    @IBAction func searchButtonTapped(_ sender: UIButton) { presentSearchView() }
    @IBAction func zoomInButtonTapped(_ sender: UIButton) { mapManager.zoomIn() }
    @IBAction func zoomOutButtonTapped(_ sender: UIButton) { mapManager.zoomOut() }
    @IBAction func menuButtonTapped(_ sender: UIButton) { presentSettingsView() }
    @IBAction func centerLocationButtonTapped(_ sender: UIButton) {
        let success = mapManager.centerLocation()
        if !success {
            let alert = UIAlertController(title: "Your Location is Unavailable", message: "Make sure you have location permissions enabled", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Helper Functions

extension MapBoxViewController {
    private func setupMapManager() {
        guard let mapView = mapView, let locationManager = locationManager else {
            return
        }
        mapManager.setupMapView(with: mapView, locationManager: locationManager)
    }

    private func setupMapButtons() {
        configureMapButton(button: searchButton, state: MapButtonState.search)
        configureMapButton(button: centerMapButton, state: MapButtonState.center)
        configureMapButton(button: zoomInButton, state: MapButtonState.zoomIn)
        configureMapButton(button: zoomOutButton, state: MapButtonState.zoomOut)
        menuButton.tag = MapButtonState.menu.tag
    }

    private func configureMapButton(button: UIButton, state: MapButtonState) {
        button.setImage(state.image, for: .normal)
        button.tag = state.tag
    }

    private func presentSearchView() {
        let storyboard = UIStoryboard.init(name: "Search", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "Search") as! SearchViewController
        searchVC.delegate = self
        present(searchVC, animated: true, completion: nil)
    }

    private func presentSettingsView() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        guard let settingsVC = storyboard.instantiateViewController(withIdentifier: "Settings") as? SettingsViewController else { return }
        settingsVC.navigationItem.title = "Settings"
        settingsVC.locationManager = locationManager
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - SDL Notifications

extension MapBoxViewController {
    @objc private func setAsRootViewController(_ notification: Notification) {
        guard sdlMapViewTouchManager != nil else { return }

        if (ProxyManager.isOffScreenStreaming) {
            ProxyManager.sharedManager.sdlManager.streamManager?.rootViewController = self
        } else {
            for window in UIApplication.shared.windows {
                if (!(window.rootViewController?.isKind(of: SDLMenuViewController.self) ?? false)) { continue }
                window.rootViewController = self
                ProxyManager.sharedManager.sdlManager.streamManager?.rootViewController = window.rootViewController
                break
            }
        }

        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
        ProxyManager.sharedManager.sdlManager.streamManager?.touchManager.touchEventDelegate = sdlMapViewTouchManager

        if let dict = notification.object as? [String: MKMapItem] {
            guard let mapItem = dict["mapItem"] else { return }
            
            mapManager.setNewAnnotation(at: mapItem.placemark.coordinate)
        }
    }
}

// MARK: - SearchViewControllerDelegate

extension MapBoxViewController: SearchViewControllerDelegate {
    func didSelectPlace(coordinate: CLLocationCoordinate2D) {
        mapManager.setNewAnnotation(at: coordinate)
    }
}

extension MapBoxViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            let size: CGFloat = 25

            let userAnnotationView = MGLUserLocationAnnotationView()
            userAnnotationView.frame = CGRect(x: 0, y: 0, width: size, height: size)
            userAnnotationView.backgroundColor = .systemBlue
            userAnnotationView.layer.borderColor = UIColor.white.cgColor
            userAnnotationView.layer.borderWidth = 3
            userAnnotationView.layer.cornerRadius = size / 2

            return userAnnotationView
        }
        return nil
    }
}
