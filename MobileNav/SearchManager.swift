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
}
