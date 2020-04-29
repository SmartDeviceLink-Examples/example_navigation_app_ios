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
    private var mapTouchHandler: TouchHandler?
    private var menuTouchHandler: TouchHandler?

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
            }
        } else {
            mapManager.setupMapView(with: mapView, userLocation: nil)
        }
    }

    func presentKeyboard() {
        ProxyManager.sharedManager.sdlManager.screenManager.presentKeyboard(withInitialText: "Search for location", delegate: self)
    }
}

extension MapBoxViewController: SDLKeyboardDelegate {
    func userDidSubmitInput(_ inputText: String, withEvent source: SDLKeyboardEvent) {
        let searchManager = SearchManager()
        switch source {
        case .voice:
            searchManager.getSearchResults(from: inputText)
        case .submitted:
            searchManager.getSearchResults(from: inputText)
        default: break
        }
    }

    func keyboardDidAbort(withReason event: SDLKeyboardEvent) {
        print("Keyboard was aborted")
    }
}

extension MapBoxViewController: SDLTouchManagerDelegate {
    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {
        if let view = view {
            switch view {
            case is UIButton:
                if menuButton.frame.contains(point) {
                    guard let touchHandler = menuTouchHandler else { return }
                    touchHandler(point, nil, .singleTap)
                }

                if searchButton.frame.contains(point) {
                    presentKeyboard()
                }
            default:break
            }
        } else {
            guard let touchHandler = mapTouchHandler else { return }
            touchHandler(point, nil, .singleTap)
        }
    }


    func touchManager(_ manager: SDLTouchManager, didReceiveDoubleTapFor view: UIView?, at point: CGPoint) {
        // Double tap will be disabled if the `tapTimeThreshold` is set to 0
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .doubleTap)
    }

    // MARK: - Pan

    func touchManager(_ manager: SDLTouchManager, panningDidStartIn view: UIView?, at point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .panStarted)
    }

    func touchManager(_ manager: SDLTouchManager, didReceivePanningFrom fromPoint: CGPoint, to toPoint: CGPoint) {
        guard let touchHandler = mapTouchHandler else { return }
        let displacementPoint = fromPoint.displacement(toPoint: toPoint)
        touchHandler(displacementPoint, nil, .panMoved)
    }

    func touchManager(_ manager: SDLTouchManager, panningDidEndIn view: UIView?, at point: CGPoint) {
        guard let touchHandler = self.mapTouchHandler else { return }
        touchHandler(point, nil, .panEnded)
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

