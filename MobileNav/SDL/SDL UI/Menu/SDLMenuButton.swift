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
        if ProxyManager.sharedManager.rpcVersion! < 6 {
            guard let menuViewController = SDLViewControllers.menu else {
                SDLLog.e("Error loading the SDL menu view controller")
                return
            }

            if ProxyManager.isOffScreenStreaming {
                ProxyManager.sharedManager.sdlManager.streamManager?.rootViewController = menuViewController
            } else {
                guard let menuViewController = SDLViewControllers.menu else {
                    SDLLog.e("Error loading the SDL menu view controller")
                    return
                }
                menuViewController.setupTouchManager()
                for window in UIApplication.shared.windows {
                    if (!(window.rootViewController?.isKind(of: MapBoxViewController.self) ?? false)) { continue }
                    window.rootViewController = menuViewController
                    ProxyManager.sharedManager.sdlManager.streamManager?.rootViewController = window.rootViewController
                    break
                }
            }

            NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
            menuViewController.setupTouchManager()
            return
        }
        ProxyManager.sharedManager.sdlManager.screenManager.openMenu()
    }
}
