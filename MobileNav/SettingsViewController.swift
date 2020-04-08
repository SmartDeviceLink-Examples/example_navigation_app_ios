//
//  SettingsViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 4/8/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTableView: UITableView!
    var settingsOptions = ["Render Type", "Stream Type"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        settingsTableView.tableFooterView = UIView()
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = settingsOptions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showSettingOptions", sender: self)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Video Stream Settings"
    }

}
