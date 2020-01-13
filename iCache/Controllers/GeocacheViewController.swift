//
//  GeocacheViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/10/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class GeocacheViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var difficultyView1: UIView!
    @IBOutlet weak var difficultyView2: UIView!
    @IBOutlet weak var difficultyView3: UIView!
    @IBOutlet weak var difficultyView4: UIView!
    @IBOutlet weak var difficultyView5: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
     
    var geocache: Geocache?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cache = geocache {
            let coords = cache.location.coordinate
            
            let anno = MKPointAnnotation()
            anno.coordinate = coords
            
            mapView.addAnnotation(anno)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: cache.location.coordinate, span: span)
            
            mapView.setRegion(region, animated: false)
            
            nameLabel.text = cache.name
            
            switch cache.difficulty {
                case 0...1:
                    difficultyView1.backgroundColor = UIColor(named: K.BrandColors.green)
                    difficultyLabel.textColor = UIColor(named: K.BrandColors.green)
                    
                case 1.1...2:
                    difficultyView1.backgroundColor = UIColor(named: K.BrandColors.green)
                    difficultyView2.backgroundColor = UIColor(named: K.BrandColors.green)
                    difficultyLabel.textColor = UIColor(named: K.BrandColors.green)
                case 2.1...3:
                    difficultyView1.backgroundColor = UIColor(named: K.BrandColors.yellow)
                    difficultyView2.backgroundColor = UIColor(named: K.BrandColors.yellow)
                    difficultyView3.backgroundColor = UIColor(named: K.BrandColors.yellow)
                    difficultyLabel.textColor = UIColor(named: K.BrandColors.yellow)
                case 3.1...4:
                    difficultyView1.backgroundColor = UIColor(named: K.BrandColors.orange)
                    difficultyView2.backgroundColor = UIColor(named: K.BrandColors.orange)
                    difficultyView3.backgroundColor = UIColor(named: K.BrandColors.orange)
                    difficultyView4.backgroundColor = UIColor(named: K.BrandColors.orange)
                    difficultyLabel.textColor = UIColor(named: K.BrandColors.orange)
                case 4.1...5:
                    difficultyView1.backgroundColor = UIColor(named: K.BrandColors.red)
                    difficultyView2.backgroundColor = UIColor(named: K.BrandColors.red)
                    difficultyView3.backgroundColor = UIColor(named: K.BrandColors.red)
                    difficultyView4.backgroundColor = UIColor(named: K.BrandColors.red)
                    difficultyView5.backgroundColor = UIColor(named: K.BrandColors.red)
                    difficultyLabel.textColor = UIColor(named: K.BrandColors.red)
                default:
                    break
            }
            
            difficultyLabel.text = "Difficulty: " + String(format: "%.1f", cache.difficulty)
            
            usernameLabel.text = "Placed by: " + cache.placedBy.capitalized
            dateLabel.text = "On: " + cache.getDateString()
        }
    }
    
    @IBAction func navigatePressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.navigationSegue, sender: self)
    }
    
    @IBAction func logPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Found It!", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: K.Segues.logSegue, sender: self)
        }))
        alertController.addAction(UIAlertAction(title: "Did Not Find", style: .default, handler: { (_) in
            let usersRef = self.db.collection("users")
            
            usersRef.whereField("email", isEqualTo: Auth.auth().currentUser!.email!)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print(error)
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if let log = data["log"] as? String {
                                let logs = Log.parseLog(log: log)
                                
                                if Log.checkGeocache(geocache: self.geocache!, logs: logs) {
                                    let newLog = Log.addGeocacheToLog(log: log, geocache: self.geocache!, isSuccess: false)
                                    let ref = self.db.collection("users").document(document.documentID)
                                    ref.updateData([
                                        "log": newLog
                                    ])
                                } else {
                                    let alertController = UIAlertController(title: "Geocache already logged today", message: "Please try again tomorrow!", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    
                                    self.present(alertController, animated: true)
                                }
                            } else {
                                let newLog = Log.addGeocacheToLog(log: nil, geocache: self.geocache!, isSuccess: false)
                                let ref = self.db.collection("users").document(document.documentID)
                                ref.updateData([
                                    "log": newLog
                                ])
                            }
                        }
                    }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.navigationSegue {
            if let viewController = segue.destination as? NavigateViewController {
                viewController.destination = geocache?.location
                viewController.geocache = geocache
            }
        } else if segue.identifier == K.Segues.logSegue {
            if let viewController = segue.destination as? CameraViewController {
                viewController.geocache = geocache
            }
        }
    }
}
