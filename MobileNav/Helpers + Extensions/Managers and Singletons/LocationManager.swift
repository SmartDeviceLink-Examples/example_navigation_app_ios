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
    private var userLocationManager = CLLocationManager()
    private(set) var userLocation: CLLocation?
    private var lastLocationUpdate = Date(timeIntervalSince1970: 0)
    var userLocationUpdatedHandler: ((CLLocation) -> Void)?

    override init() {
        super.init()
        userLocationManager.delegate = self
        userLocationManager.pausesLocationUpdatesAutomatically = true
        userLocationManager.desiredAccuracy = 1000
        userLocationManager.distanceFilter = 500
        userLocationManager.requestWhenInUseAuthorization()

        // Set Detroit location as the default location
        let detroitLocation = CLLocation(latitude: 42.33, longitude: -83.04)
        userLocation = detroitLocation
    }

    convenience init(userLocationUpdatedHandler: ((CLLocation) -> Void)?) {
        self.init()
        self.userLocationUpdatedHandler = userLocationUpdatedHandler
        userLocationManager.startMonitoringSignificantLocationChanges()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocationManager.stopUpdatingLocation()
        let date = Date()
        if date.timeIntervalSince(self.lastLocationUpdate) <= 120 {
            return
        }

        self.lastLocationUpdate = date
        userLocation = locations.last

        guard let userLocationUpdatedHandler = userLocationUpdatedHandler, let userLocation = userLocation else { return }
        userLocationUpdatedHandler(userLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            userLocationManager.startUpdatingLocation()
        case .denied:
            print("Cannot access user location, permission was denied by user.")
        default:
            break
        }
    }
}
