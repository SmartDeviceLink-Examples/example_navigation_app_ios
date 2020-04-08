//
//  SettingOptionsViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 4/8/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit

class SettingOptionsViewController: UIViewController {

    @IBOutlet weak var optionsTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}

extension SettingOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "test"
        return cell
    }


}
