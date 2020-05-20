//
//  Extensions.swift
//  MobileNav
//
//  Created by James Lapinski on 5/14/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit

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

extension Notification.Name {

    /** A notification that informs the receiver to present the OffScreenViewController. */
    static let offScreenConnected = Notification.Name("offScreenConnected")

    /** A notification that informs the receiver to dismiss the OffScreenViewController */
    static let offScreenDisconnected = Notification.Name("offScreenDisconnected")

    /** A notification that informs observing receivers about significant location updates. */
    static let locationUpdated = Notification.Name("locationUpdated")

    /** A notification that informs the receiver to hide projected buttons subscribed through SDL */
    static let hideSubscribedButtons = Notification.Name("hideSubscribedButtons")

    /** A notification that informs the receiver to show previously hidden buttons */
    static let showHiddenButtons = Notification.Name("showHiddenButtons")

    /** A notification that informs the receiver center map on place */
    static let sdl_centerMapOnPlace = Notification.Name("sdl_centerMapOnPlace")
}
