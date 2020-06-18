//
//  MapButtonState.swift
//  MobileNav
//
//  Created by Nicole on 6/18/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit

enum MapButtonState {
    case search
    case center
    case zoomIn
    case zoomOut
    case menu

    var tag: Int {
        switch self {
        case .search: return 1
        case .center: return 2
        case .zoomIn: return 3
        case .zoomOut: return 4
        case .menu: return 5
        }
    }

    var image: UIImage? {
        switch self {
        case .search: return UIImage(named: "search")
        case .center: return UIImage(named: "center")
        case .zoomIn: return UIImage(named: "zoom_in")
        case .zoomOut: return UIImage(named: "zoom_out")
        case .menu: return nil
        }
    }
}
