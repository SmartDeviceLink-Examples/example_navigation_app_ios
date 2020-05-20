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

    func searchFor(searchTerm: String, handler: @escaping (_ mapItems:[MKMapItem]?, _ error:Error?)-> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                handler(nil, error)
                return
            }

            if let response = response {
                handler(response.mapItems, nil)
            }
        }
    }

}
