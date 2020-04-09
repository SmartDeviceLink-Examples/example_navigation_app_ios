//
//  SettingsViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 4/8/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import UIKit
import SmartDeviceLink

class SettingsViewController: UIViewController {

    private var settingOptions = [String]()
    private var selectedRenderType: RenderType?
    private var selectedStreamType: StreamType?

    @IBOutlet weak var settingsTableView: UITableView!
    @IBAction func startPressed(_ sender: UIButton) {
        if let selectedRenderType = selectedRenderType, let selectedStreamType = selectedStreamType {
            startSDL(with: selectedRenderType, streamType: selectedStreamType)
        } else {
            presentAlertController()
        }
    }

    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        settingsTableView.tableFooterView = UIView()
    }

    private func presentAlertController() {
        let alert = UIAlertController(title: "Incomplete Form", message: "You must select a render type and stream type before proceeding", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }

    private func startSDL(with renderType:RenderType, streamType:StreamType) {
        let carWindowRenderType: SDLCarWindowRenderingType
        var isOffScreen: Bool = false

        switch renderType {
        case .layer:
            carWindowRenderType = .layer
        case .viewAfterScreenUpdates:
            carWindowRenderType = .viewAfterScreenUpdates
        case .viewBeforeScreenUpdates:
            carWindowRenderType = .viewBeforeScreenUpdates
        }

        switch streamType {
        case .offScreen:
            isOffScreen = true
        case .onScreen:
            isOffScreen = false
        }

        let streamSettings = StreamSettings(renderType: carWindowRenderType, isOffScreen: isOffScreen)
        ProxyManager.sharedManager.connect(with: .iap, streamSettings: streamSettings)
    }
}

extension SettingsViewController: OptionSelectedDelegate {
    func optionSelected(option: Int) {
        if settingOptions == RenderType.allCases.map({ $0.description }) {
            selectedRenderType = RenderType(rawValue: option)
        } else {
            selectedStreamType = StreamType(rawValue: option)
        }
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsSection.allCases.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = SettingsSection(rawValue: indexPath.row)?.description
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.row) else { return }
        switch section {
        case .render:
            settingOptions = RenderType.allCases.map { $0.description }
        case .stream:
            settingOptions = StreamType.allCases.map { $0.description }
        }

        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showSettingOptions", sender: self)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Video Stream Settings"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingOptionsViewController = segue.destination as? SettingOptionsViewController {
            settingOptionsViewController.options = settingOptions
            settingOptionsViewController.delegate = self
        }
    }
}
