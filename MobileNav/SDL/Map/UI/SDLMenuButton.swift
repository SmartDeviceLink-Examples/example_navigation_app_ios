//
//  SDLMenuButton.swift
//  MobileNav
//
//  Created by James Lapinski on 4/14/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit

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
        backgroundColor = .systemPink
        layer.cornerRadius = 10
        clipsToBounds = true

        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 1
        titleLabel?.lineBreakMode = .byCharWrapping
        titleLabel?.font = UIFont.systemFont(ofSize: 64)
    }

}

extension SDLMenuButton {
    var buttonTouchHandler: TouchHandler? {
        return { [unowned self] (touchPoint: CGPoint, scale: CGFloat?, touchType: TouchType) in
            switch touchType {
            case .singleTap:
                self.buttonSelected()
            default: break
            }
        }
    }

    private func buttonSelected() {
        // to do
        print("button tapped")
    }
}
