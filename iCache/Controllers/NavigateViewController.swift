//
//  NavigateViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/10/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import MapKit

class NavigateViewController: UIViewController {
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var navigationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recenterButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var destination: CLLocation?
    var geocache: Geocache?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        
        let anno = MKPointAnnotation()
        
        if let coords = destination {
            anno.coordinate = coords.coordinate
            anno.title = "Destination"
            
            mapView.addAnnotation(anno)
        }
        
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager(locationManager, didChangeAuthorization: CLLocationManager.authorizationStatus())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func recenterPressed(_ sender: UIButton) {
        recenterButton.isHidden = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mapView.setUserTrackingMode(.followWithHeading, animated: false)
    }
}

extension NavigateViewController: CLLocationManagerDelegate {
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
        let coordinates: [CLLocationCoordinate2D] = [destination!.coordinate, locationManager.location!.coordinate]
        
        if let location = locations.last {
            let distanceInMeters = location.distance(from: destination!)
            
            var convertedDistance: Double
            var isFeet = false
            
            if distanceInMeters < 610 {
                convertedDistance = distanceInMeters * 3.281
                isFeet = true
            } else {
                convertedDistance = distanceInMeters / 1609.0
            }
            
            if isFeet {
                let distance = round(convertedDistance)
                switch convertedDistance {
                    case 0...200:
                        if distance < 100 {
                            hintLabel.text = geocache?.hints[1]
                            navigationLabel.text = "<100 Feet"
                        } else {
                            hintLabel.text = geocache?.hints[0]
                            navigationLabel.text = "<200 Feet"
                        }
                        
                        mapView.removeOverlays(mapView.overlays)
                    case 201...1000:
                        navigationLabel.text = "\(Int(round(distance / 100) * 100)) Feet"
                        hintLabel.text = K.hintMessage
                        
                        let line = MKPolyline(coordinates: coordinates, count: coordinates.count)
                        mapView.addOverlay(line)
                    case 1001...2000:
                        navigationLabel.text = "\(Int(round(distance / 500) * 500)) Feet"
                        hintLabel.text = K.hintMessage
                        
                        let line = MKPolyline(coordinates: coordinates, count: coordinates.count)
                        mapView.addOverlay(line)
                    default:
                        break
                }
            } else {
                hintLabel.text = K.hintMessage
                navigationLabel.text = String(format: "%.1f", convertedDistance) + " Miles"
            }
            
            if (mapView.overlays.count > 1) {
                mapView.removeOverlay(mapView.overlays[0])
            }
        }
    }
}

extension NavigateViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if (mode != .followWithHeading) {
            recenterButton.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay);
        renderer.strokeColor = UIColor.red.withAlphaComponent(0.5)
        renderer.lineWidth = 5
        
        return renderer
    }
}
