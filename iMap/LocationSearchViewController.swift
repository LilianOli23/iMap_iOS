//
//  LocationSearchViewController.swift
//  iMap
//
//  Created by Lilian De Oliveira Silva on 07/05/22.
//

import UIKit
import MapKit

class LocationSearchViewController: UITableViewController {
    
    var matchingItems : [MKMapItem] = []
    var mapView : MKMapView? = nil
    var handleMapSearchDelegate : HandleMapSearch? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    //MARK: Helpers functions
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil
                          && selectedItem.thoroughfare != nil) ? " ": ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ?
        ", ": ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " ": ""
        let addresLine = String(
            format: "%@%@%@%@%@%@%@",
            //street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            //street name
            selectedItem.thoroughfare ?? "",
            comma,
            //city
            selectedItem.locality ?? "",
            secondSpace,
            //state
            selectedItem.administrativeArea ?? ""
            
        )
        return addresLine
    }

}
extension LocationSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else {return}
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            guard let response = response else {return}
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
            
        }
    }
}
extension LocationSearchViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let selectedItem = matchingItems[indexPath.row].placemark
        cell?.textLabel?.text = selectedItem.name
        cell?.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIN(placemark: selectedItem)
        
        dismiss(animated: true, completion: nil)
    }
}
