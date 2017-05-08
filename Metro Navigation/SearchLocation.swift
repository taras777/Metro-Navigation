//
//  SearchLocation.swift
//  Metro Navigation
//
//  Created by Taras on 5/8/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import MapKit

class SearchLocation: UITableViewController {
  
  
  weak var handleMapSearchDelegate: HandleMapSearch?
  var matchingItems: [MKMapItem] = []
  var mapView: MKMapView?
  
  
  func parseAddress(_ selectedItem:MKPlacemark) -> String {
    
    //Put a space between "7" and "Khreshchatyk"
    let firstSpace = (selectedItem.subThoroughfare != nil &&
      selectedItem.thoroughfare != nil) ? " " : ""
    
    //Put a comma between street and city/ state
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
      (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
    
    //Put a space between "Washington" and "DC"
    let secondSpace = (selectedItem.subAdministrativeArea != nil &&
      selectedItem.administrativeArea != nil) ? " " : ""
    
    let addressLine = String(
      format:"%@%@%@%@%@%@%@",
      //Street number
      selectedItem.subThoroughfare ?? "",
      firstSpace,
      //Street name
      selectedItem.thoroughfare ?? "",
      comma,
      //City
      selectedItem.locality ?? "",
      secondSpace,
      //State
      selectedItem.administrativeArea ?? ""
    )
    
    return addressLine
  }
}

extension SearchLocation : UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let mapView = mapView,
      let searchBarText = searchController.searchBar.text else {
        return
    }
    
    let request = MKLocalSearchRequest()
    request.naturalLanguageQuery = searchBarText
    request.region = mapView.region
    let search = MKLocalSearch(request: request)
    
    search.start { response, _ in
      guard let response = response else {
        return
      }
      self.matchingItems = response.mapItems
      self.tableView.reloadData()
    }
    
  }
  
}

extension SearchLocation {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return matchingItems.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
    cell.textLabel?.text = selectedItem.name
    cell.detailTextLabel?.text = parseAddress(selectedItem)
    return cell
  }
  
}

extension SearchLocation {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
    handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
    dismiss(animated: true, completion: nil)
  }
  
}
