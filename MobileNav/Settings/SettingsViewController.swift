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
    var proxyState = ProxyState.stopped

    @IBOutlet weak var settingsTableView: UITableView!
    @IBAction func startPressed(_ sender: UIButton) {
        if let selectedRenderType = selectedRenderType, let selectedStreamType = selectedStreamType {

            switch proxyState {
            case .stopped:
                startSDL(with: selectedRenderType, streamType: selectedStreamType)
            case .searching:
                ProxyManager.sharedManager.stopConnection()
            case .connected:
                ProxyManager.sharedManager.stopConnection()
            }
        } else {
            presentAlertController()
        }
    }

    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        ProxyManager.sharedManager.delegate = self
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
        let viewControllerToStream = UIStoryboard(name: "SDLMapBoxMap", bundle: nil).instantiateInitialViewController() as? MapBoxViewController

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

        let streamSettings = StreamSettings(renderType: carWindowRenderType, isOffScreen: isOffScreen, viewControllerToStream:viewControllerToStream!)
        ProxyManager.sharedManager.connect(with: .iap, streamSettings: streamSettings)

        if !isOffScreen {
            self.show(viewControllerToStream!, sender: self)
            return
        }
    }
}

extension SettingsViewController: ProxyManagerDelegate {
    func didChangeProxyState(_ newState: ProxyState) {
        proxyState = newState
        var newColor: UIColor? = nil
        var newTitle: String? = nil

        switch newState {
        case .stopped:
            newColor = UIColor.systemGreen
            newTitle = "Start".uppercased()
        case .searching:
            newColor = UIColor.systemBlue
            newTitle = "Stop Searching".uppercased()
        case .connected:
            newColor = UIColor.systemRed
            newTitle = "Disconnect".uppercased()
        }

        if (newColor != nil) || (newTitle != nil) {
            DispatchQueue.main.async(execute: {[weak self]() -> Void in
                self?.startButton.backgroundColor = newColor
                self?.startButton.setTitle(newTitle, for: .normal)
            })
        }
    }
}

extension SettingsViewController: SettingOptionsViewControllerDelegate {
    func optionSelected(option: Int) {
        if settingOptions == RenderType.allCases.map({ $0.description }) {
            selectedRenderType = RenderType(rawValue: option)
        } else {
            selectedStreamType = StreamType(rawValue: option)
        }
        settingsTableView.reloadData()
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

        if SettingsSection(rawValue: indexPath.row)?.description == "Render Type" {
            cell.detailTextLabel?.text = self.selectedRenderType?.description
        } else if SettingsSection(rawValue: indexPath.row)?.description == "Stream Type" {
            cell.detailTextLabel?.text = self.selectedStreamType?.description
        }

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