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
    
    let db = Firestore.firestore()
    
    var geocaches: [Geocache] = []
    var selectedGeocache: Geocache? = nil
    
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
        
        loadGeocaches()
        
        navigateToCurrentLocation()
    }
    
    func loadGeocaches() {
        db.collection("geocaches").getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                if let snapshot = querySnapshot {
                    let documents = snapshot.documents
                    for document in documents {
                        let data = document.data()
                        
                        let username = data["placedBy"] as! String
                        let name = data["name"] as! String
                        let date = data["datePlaced"] as! Double
                        let datePlaced = Date(timeIntervalSince1970: date)
                        let difficulty = data["difficulty"] as! Double
                        let locationGeopoint = data["location"] as! GeoPoint
                        let location = CLLocation(latitude: CLLocationDegrees(exactly: locationGeopoint.latitude)!, longitude: CLLocationDegrees(exactly: locationGeopoint.longitude)!)
                        let hint1 = data["hint1"] as! String
                        let hint2 = data["hint2"] as! String
                        let hints = [hint1, hint2]
                        let id = document.documentID
                        
                        let geocache = Geocache(name: name, placedBy: username, datePlaced: datePlaced, difficulty: difficulty, location: location, hints: hints, id: id)
                        
                        self.geocaches.append(geocache)
                    }
                    
                    for geocache in self.geocaches {
                        let coords = geocache.location.coordinate
                        
                        let anno = MKPointAnnotation()
                        anno.coordinate = coords
                        anno.title = "Geocache"
                        
                        self.mapView.addAnnotation(anno)
                    }
                }
            }
        }
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
                let alertController = UIAlertController(title: "Location Access Required", message: K.noLocationMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Go To Settings", style: .default, handler: { (_) in
                    UIApplication.shared.open(URL(string: K.settingsPath)!, options: [:], completionHandler: nil)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        
        let smallSquare = CGSize(width: 30, height: 30)
        
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(systemName: "info.circle"), for: .normal)
        button.addTarget(self, action: #selector(annotationClicked), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
    
    @objc func annotationClicked() {
        performSegue(withIdentifier: K.Segues.geocacheSegue, sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation!
        
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        
        for geocache in geocaches {
            if geocache.location.coordinate.longitude == lon && geocache.location.coordinate.latitude == lat {
                selectedGeocache = geocache
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.geocacheSegue {
            if let viewController = segue.destination as? GeocacheViewController {
                viewController.geocache = selectedGeocache
            }
        }
    }
}
