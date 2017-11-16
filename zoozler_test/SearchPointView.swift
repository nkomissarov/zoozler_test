//
//  SearchPointView.swift
//  zoozler_test
//
//  Created by Nick Komissarov on 11/16/17.
//  Copyright © 2017 Nick Komissarov. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

protocol SearchPointViewDelegate {
    func didPointChanged(view: SearchPointView, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class SearchPointView : UIView,GMSAutocompleteResultsViewControllerDelegate, UISearchBarDelegate{
    var delegate : SearchPointViewDelegate?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var originalOffset:CGFloat = 0
    var text: String = "Search"
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    init(frame: CGRect, text: String){
        super.init(frame: frame)
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchBar.delegate = self
        searchController?.searchResultsUpdater = resultsViewController
        addSubview((searchController?.searchBar)!)
        searchController?.searchBar.frame = CGRect(x: 0, y: 0, width: frame.width + layoutMargins.left + layoutMargins.right, height: frame.height + layoutMargins.top + layoutMargins.bottom)
        self.text = text;
        searchController?.searchBar.text = text;
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        //searchController?.searchBar.sizeToFit()
        searchController?.searchBar.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height + layoutMargins.top + layoutMargins.bottom)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchController?.searchBar.text = "";
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchController?.searchBar.text = text
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
        self.text = place.name
        searchController?.searchBar.text = text
        delegate?.didPointChanged(view: self, latitude: self.latitude, longitude: longitude)
    }
    
    func setCoordinates(position: CLLocationCoordinate2D)
    {
        latitude = position.latitude
        longitude = position.longitude
        delegate?.didPointChanged(view: self, latitude: latitude, longitude: longitude)
        text = "\(latitude), \(longitude)"
        searchController?.searchBar.text = text
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
