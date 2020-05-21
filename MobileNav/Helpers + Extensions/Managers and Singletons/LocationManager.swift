//
//  LocationManager.swift
//  MobileNav
//
//  Created by James Lapinski on 5/19/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import CoreLocation
import Foundation

class LocationManager: NSObject {
    static let sharedManager = LocationManager()
    private var locationManager = CLLocationManager()
    private var lastLocationUpdate = Date(timeIntervalSince1970: 0)
    var userLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = 1000
        locationManager.distanceFilter = 500
        locationManager.requestWhenInUseAuthorization()
    }

    func start() {
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func stop() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let date = Date()
        if date.timeIntervalSince(self.lastLocationUpdate) <= 120 {
            return
        }

        self.lastLocationUpdate = date
        userLocation = locations.last
        NotificationCenter.default.post(Notification(name: .locationUpdated))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            print("Cannot access user location, permission was denied by user.")
        default:
            break
        }
    }
}
