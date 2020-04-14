//
//  SettingOptionsViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 4/8/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit

protocol SettingOptionsViewControllerDelegate: class {
    func optionSelected(option: Int)
}

class SettingOptionsViewController: UIViewController {
    @IBOutlet weak var optionsTableView: UITableView!
    weak var delegate: SettingOptionsViewControllerDelegate?
    var options = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.optionsTableView.delegate = self
        self.optionsTableView.dataSource = self
        optionsTableView.tableFooterView = UIView()
    }
}

extension SettingOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose an option"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.optionSelected(option: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }

}
