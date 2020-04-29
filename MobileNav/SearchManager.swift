//
//  SearchManager.swift
//  MobileNav
//
//  Created by James Lapinski on 4/29/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import MapKit

class SearchManager: NSObject {

    func getSearchResults(from query:String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            for item in response!.mapItems {
                print(item.name)
            }
        }
    }

}
