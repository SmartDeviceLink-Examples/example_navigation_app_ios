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
    func searchFor(searchTerm: String, handler: @escaping (_ mapItems: [MKMapItem]?, _ error: Error?) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                guard let error = error else { return }
                return handler(nil, error)
            }

            return handler(response.mapItems, nil)
        }
    }
}
