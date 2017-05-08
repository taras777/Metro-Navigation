//
//  ViewController.swift
//  Metro Navigation
//
//  Created by Taras on 5/5/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
  func dropPinZoomIn(_ placemark:MKPlacemark)
}

class ViewController: UIViewController {
  
  var selectedPin: MKPlacemark?
  var resultSearchController: UISearchController!
  
  let locationManager = CLLocationManager()
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func button3(_ sender: AnyObject) {
    getDirections()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
    let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "SearchLocation") as! SearchLocation
    resultSearchController = UISearchController(searchResultsController: locationSearchTable)
    resultSearchController.searchResultsUpdater = locationSearchTable
    let searchBar = resultSearchController!.searchBar
    searchBar.sizeToFit()
    searchBar.placeholder = "Search"
    navigationItem.titleView = resultSearchController?.searchBar
    resultSearchController.hidesNavigationBarDuringPresentation = false
    resultSearchController.dimsBackgroundDuringPresentation = true
    definesPresentationContext = true
    locationSearchTable.mapView = mapView
    locationSearchTable.handleMapSearchDelegate = self
    
  }
  
  func getDirections(){
    guard let selectedPin = selectedPin else {
      return
    }
    let mapItem = MKMapItem(placemark: selectedPin)
    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    mapItem.openInMaps(launchOptions: launchOptions)
  }
}

extension ViewController : CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse {
      locationManager.requestLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    let span = MKCoordinateSpanMake(0.05, 0.05)
    let region = MKCoordinateRegion(center: location.coordinate, span: span)
    mapView.setRegion(region, animated: true)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error:: \(error)")
  }
  
}

extension ViewController: HandleMapSearch {
  
  func dropPinZoomIn(_ placemark: MKPlacemark){
    //cache the pin
    selectedPin = placemark
    //clear existing pins
    mapView.removeAnnotations(mapView.annotations)
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    annotation.title = placemark.name
    
    if let city = placemark.locality,
      let state = placemark.administrativeArea {
      annotation.subtitle = "\(city) \(state)"
    }
    
    mapView.addAnnotation(annotation)
    let span = MKCoordinateSpanMake(0.05, 0.05)
    let region = MKCoordinateRegionMake(placemark.coordinate, span)
    mapView.setRegion(region, animated: true)
  }
}

extension ViewController : MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
    
    guard !(annotation is MKUserLocation) else {
      return nil
    }
    
    let reuseId = "pin"
    guard let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView else { return nil
    }
    
    pinView.pinTintColor = UIColor.purple
    pinView.canShowCallout = true
    let smallSquare = CGSize(width: 30, height: 30)
    var button: UIButton?
    button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
    button?.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
    button?.addTarget(self, action: #selector(ViewController.getDirections), for: .touchUpInside)
    pinView.leftCalloutAccessoryView = button
    
    return pinView
  }
}
