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
