//
//  SearchViewController.swift
//  MobileNav
//
//  Created by James Lapinski on 5/13/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import MapKit
import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func didSelectPlace(coordinate:CLLocationCoordinate2D)
}

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!

    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    weak var delegate: SearchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row].title
        cell.detailTextLabel?.text = searchResults[indexPath.row].subtitle

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = searchResults[indexPath.row]
        let request = MKLocalSearch.Request()
        let query: String = place.subtitle != "" ? place.title + ", " + place.subtitle : place.title
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)

        search.start { (response, error) in
            guard let response = response else { return }
            guard let item = response.mapItems.first else { return }
            let itemCoordinate = item.placemark.coordinate
            self.delegate?.didSelectPlace(coordinate: itemCoordinate)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else { return }
        searchCompleter.queryFragment = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension SearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
