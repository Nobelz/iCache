//
//  MapViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/6/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    
    var resultSearchController: UISearchController? = nil
    
    var mapChangedFromUserInteraction = false
    var timer = Timer()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: K.searchControllerId) as! SearchViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        locationSearchTable.mapView = mapView
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationManager.delegate = self
        mapView.delegate = self
        
        locationButton.layer.cornerRadius = 0.5 * locationButton.bounds.size.width
        
        navigateToCurrentLocation()
    }

    func navigateToCurrentLocation() {
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            locationManager.requestLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager(locationManager, didChangeAuthorization: CLLocationManager.authorizationStatus())
        }
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        if mapView.userTrackingMode == .follow {
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            locationButton.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
        } else if mapView.userTrackingMode == .followWithHeading {
            mapView.setUserTrackingMode(.none, animated: true)
            locationButton.tintColor = UIColor(named: K.BrandColors.gray)
            locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        } else {
            mapView.setUserTrackingMode(.follow, animated: true)
            locationButton.tintColor = UIColor(named: K.BrandColors.blue)
            locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        }
    }
    
    func centerMapOnLocation(location: CLLocation, regionRadius: Int) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: CLLocationDistance(regionRadius), longitudinalMeters: CLLocationDistance(regionRadius))
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .denied, .restricted:
                let alertController = UIAlertController(title: "Location Access Required", message: "Go to Settings -> Privacy -> Location Services and make sure iCache's settings are set to Allow While Using, then rerun app.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Go To Settings", style: .default, handler: { (_) in
                    UIApplication.shared.open(URL(string:"App-Prefs:root=LOCATION_SERVICES")!, options: [:], completionHandler: nil)
                }))
                alertController.addAction(UIAlertAction(title: "No I'm Good", style: .destructive, handler: nil))
                self.present(alertController, animated: true)
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            centerMapOnLocation(location: CLLocation(latitude: lat, longitude: lon), regionRadius: 500)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if (mode == .none) {
            locationButton.tintColor = UIColor(named: K.BrandColors.gray)
            locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        }
    }
}
