//
//  ViewController.swift
//  iMap
//
//  Created by Lilian De Oliveira Silva on 07/05/22.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSegmentController: UISegmentedControl!
    
    private let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    var selectedPin : MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        self.mapTypeSegmentController.addTarget(self,
            action: #selector(mapTypeChanged), for: .valueChanged)
        
        //set up the search results table
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearch")
            as! LocationSearchViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = (locationSearchTable as? UISearchResultsUpdating)
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
                
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            
            let coordinate = annotation.coordinate
            
            let destinationPlacemark = MKPlacemark(coordinate: coordinate)
            
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            MKMapItem.openMaps(with: [destinationMapItem], launchOptions: nil)
            
        }
    }

   @objc func mapTypeChanged(segmentedControl: UISegmentedControl) {
        
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = .standard
        case 1:
            self.mapView.mapType = .satellite
        case 2:
            self.mapView.mapType = .hybrid
        default:
            self.mapView.mapType = .standard
        }
        
    }
    
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//
//        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
//
//        mapView.setRegion(region, animated: true)
//
//    }
    
}

protocol HandleMapSearch {
    
    func dropPinZoomIN(placemark: MKPlacemark)
    
}

extension ViewController : HandleMapSearch {
    
    func dropPinZoomIN(placemark: MKPlacemark) {
        //cache the pin
        selectedPin = placemark
        //clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
}
