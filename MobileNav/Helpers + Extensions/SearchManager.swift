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
    var results = [MKMapItem]()

    func getSearchResults(from query:String) -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                self.results = response!.mapItems
            }
            // to do error handling
        }
        return results
    }

    func findCoffeeShops() -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "coffee"
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                self.results = response!.mapItems
            }
            // to do error handling
        }
        return results
    }

    func findRestaurants() -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurants"
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                self.results = response!.mapItems
            }
            // to do error handling
        }
        return results
    }

    func findGasStations() -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "gas stations"
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                self.results = response!.mapItems
            }
            // to do error handling
        }
        return results
    }


}
