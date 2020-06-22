//
//  SDLMenuButton.swift
//  MobileNav
//
//  Created by James Lapinski on 4/14/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink

class SDLMenuButton: UIButton {
    override func awakeFromNib() {
       super.awakeFromNib()
       setupButton()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        backgroundColor = .systemBlue
        layer.cornerRadius = 10
        clipsToBounds = true

        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 1
        titleLabel?.lineBreakMode = .byCharWrapping
        titleLabel?.font = UIFont.systemFont(ofSize: 36)
    }
}
