//
//  MapButton.swift
//  MobileNav
//
//  Created by James Lapinski on 5/14/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit

class MapButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = self.bounds.height/2
        self.backgroundColor = .systemBlue
    }
}
