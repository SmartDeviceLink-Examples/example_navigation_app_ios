//
//  NotificationQueue.swift
//  MobileNav
//
//  Created by James Lapinski on 5/20/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation

class NotificationQueue {
    static let shared = NotificationQueue()
    var lastNotification: Notification?

    init() {
        // Look for notifcation to be used after user selects option when presented from SDLMenuViewController
        NotificationCenter.default.addObserver(self, selector: #selector(setLastNotificationAsCenterMap), name: .sdl_centerMapOnPlace, object: nil)
    }

    func start() { }

    @objc private func setLastNotificationAsCenterMap(_ notification: Notification) {
        lastNotification = notification
    }
}
