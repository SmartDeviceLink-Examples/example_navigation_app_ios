//
//  SearchManager.swift
//  MobileNav
//
//  Created by James Lapinski on 4/29/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import MapKit
import SmartDeviceLink

class SearchManager: NSObject {

    var choiceCells = [SDLChoiceCell]()

    func getSearchResults(from query:String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            // to do
        }
    }

    func findCoffeeShops(from userLocation:CLLocation) -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "coffee"
        request.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            // to do
        }
        return []
    }

    func findRestaurants(from userLocation:CLLocation) -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurants"
        request.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            // to do
        }
        return []
    }

    func findGasStations(from userLocation:CLLocation) -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "gas stations"
        request.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            // to do
        }
        return []
    }


}
