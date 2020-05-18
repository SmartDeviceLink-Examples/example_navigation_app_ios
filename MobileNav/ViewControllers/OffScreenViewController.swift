//
//  OffScreenViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 5/18/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink

class OffScreenViewController: UIViewController {

    @IBOutlet weak var offScreenLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(dismissViewController), name: .offScreenDisconnected, object: nil)
    }

    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }

}
