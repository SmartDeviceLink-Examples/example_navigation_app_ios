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
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var menuButton: SDLMenuButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var centerMapButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!

    private var mapViewCenterPoint: CGPoint! = .zero
    private var newMapCenterPoint: CGPoint = .zero
    private var mapZoomLevel: Double = 0.0
    var mapManager = MapManager()
    private var annotation: MGLPointAnnotation?
    private var mapTouchHandler: TouchHandler?
    private var menuTouchHandler: TouchHandler?
    private var userLocation: CLLocation?
    private var keyboard: KeyboardSearchInteraction?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
    }
}

// MARK: - Button Actions

extension MapBoxViewController {
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
}

// MARK: - Helper Functions

extension MapBoxViewController {

    func setup() {
        DispatchQueue.main.async {
            self.setupObservers()
            self.setupButtons()
            self.setupUserLocation()
        }
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(presentOffScreen), name: .offScreenConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupUserLocation), name: .locationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSubscribedButtons), name: .hideSubscribedButtons, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSubscribeButtons), name: .showSubscribeButtons, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(centerMapOnLocation), name: .centerMapOnPlace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupTouchManager), name: .setupTouchManager, object: nil)
    }

    @objc private func setupTouchManager() {
        mapTouchHandler = mapManager.mapManagerTouchHandler
        menuTouchHandler = menuButton.buttonTouchHandler
        ProxyManager.sharedManager.sdlManager.streamManager?.touchManager.touchEventDelegate = self
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


    // MARK: - Notification

    @objc func setupUserLocation() {
            mapView.showsUserLocation = true
            mapManager.setupMapView(with: mapView, location: LocationManager.sharedManager.userLocation!)
            userLocation = LocationManager.sharedManager.userLocation
    }

    @objc private func presentOffScreen() {
        let storyboard = UIStoryboard.init(name: "OffScreen", bundle: nil)
        let offScreenVC = storyboard.instantiateViewController(withIdentifier: "OffScreen") as! OffScreenViewController
        offScreenVC.modalPresentationStyle = .overFullScreen
        present(offScreenVC, animated: false, completion: nil)
    }

    @objc private func hideSubscribedButtons() {
        DispatchQueue.main.async {
            let buttonsSupported = self.subscribeButtons()

            if buttonsSupported.contains(where: { $0.name == SDLButtonName.navCenterLocation.rawValue.rawValue }) {
                self.centerMapButton.isHidden = true
            }

            if buttonsSupported.contains(where: { $0.name == SDLButtonName.navZoomIn.rawValue.rawValue }) {
                self.zoomInButton.isHidden = true
            }

            if buttonsSupported.contains(where: { $0.name == SDLButtonName.navZoomOut.rawValue.rawValue }) {
                self.zoomOutButton.isHidden = true
            }
        }
    }

    @objc private func showSubscribeButtons() {
        DispatchQueue.main.async {
            if self.centerMapButton.isHidden { self.centerMapButton.isHidden = false }
            if self.zoomOutButton.isHidden { self.zoomOutButton.isHidden = false }
            if self.zoomInButton.isHidden { self.zoomInButton.isHidden = false }
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
                DispatchQueue.main.async {
                    if self.annotation != nil {
                        self.mapView.removeAnnotation(self.annotation!)
                    }
                    self.annotation = MGLPointAnnotation()
                    self.annotation!.coordinate = mapItem.placemark.coordinate
                    self.mapView.addAnnotation(self.annotation!)
                    let location = CLLocation(latitude: self.annotation!.coordinate.latitude, longitude: self.annotation!.coordinate.longitude)
                    self.mapManager.setupMapView(with: self.mapView, location: location)
                }
            }
        }
    }
}


// MARK: - SDLTouchManagerDelegate

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
                if zoomInButton.frame.contains(point) { mapManager.zoomIn() }
                if zoomOutButton.frame.contains(point) { mapManager.zoomOut() }
                if centerMapButton.frame.contains(point) {
                    mapManager.centerLocation(lat: userLocation!.coordinate.latitude, long: userLocation!.coordinate.longitude)
                }

            default:break
            }
        } else {
            guard let touchHandler = mapTouchHandler else { return }
            touchHandler(point, nil, .singleTap)
        }
    }

    func presentKeyboard() {
        keyboard = KeyboardSearchInteraction(screenManager: ProxyManager.sharedManager.sdlManager.screenManager)
        keyboard?.present()
    }

    func touchManager(_ manager: SDLTouchManager, didReceiveDoubleTapFor view: UIView?, at point: CGPoint) {
        // Double tap will be disabled if the `tapTimeThreshold` is set to 0
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .doubleTap)
    }

    // MARK: - Pan

    func touchManager(_ manager: SDLTouchManager, didReceivePanningFrom fromPoint: CGPoint, to toPoint: CGPoint) {
        guard let touchHandler = mapTouchHandler else { return }
        let displacementPoint = fromPoint.displacement(toPoint: toPoint)
        touchHandler(displacementPoint, nil, .panMoved)
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

// MARK: - Subscribe Buttons

extension MapBoxViewController {
    private func subscribeButtons() -> [SDLSubscribeButton] {
        var subscribedButtons = [SDLSubscribeButton]()

        if buttonNameSupported(sdlButtonName: .navZoomIn) {
            let zoomInbutton = SDLSubscribeButton(buttonName: .navZoomIn) { [unowned self] (press, event) in
                guard press != nil else { return }
                self.mapManager.zoomIn()
            }
            subscribedButtons.append(zoomInbutton)
        }

        if buttonNameSupported(sdlButtonName: .navZoomOut) {
            let zoomOutButton = SDLSubscribeButton(buttonName: .navZoomOut) { [unowned self] (press, event) in
                guard press != nil else { return }
                self.mapManager.zoomOut()
            }
            subscribedButtons.append(zoomOutButton)
        }

        if buttonNameSupported(sdlButtonName: .navZoomOut) {
            let centerMapButton = SDLSubscribeButton(buttonName: .navZoomOut) { [unowned self] (press, event) in
                guard press != nil else { return }
                if let userLocation = LocationManager.sharedManager.userLocation {
                    self.mapManager.centerLocation(lat: userLocation.coordinate.latitude, long: userLocation.coordinate.longitude)
                } else {
                    Alert.presentUnableToFindLocation()
                    return
                }
            }
            subscribedButtons.append(centerMapButton)
        }

        ProxyManager.sharedManager.sdlManager.send(subscribedButtons, progressHandler: nil, completionHandler: nil)
        return subscribedButtons
    }

    func buttonNameSupported(sdlButtonName: SDLButtonName) -> Bool {
        return ProxyManager.sharedManager.sdlManager.systemCapabilityManager.defaultMainWindowCapability?.buttonCapabilities?.contains(where: { $0.name == sdlButtonName }) ?? false
    }

}
