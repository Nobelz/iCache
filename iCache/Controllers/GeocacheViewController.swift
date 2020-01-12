//
//  GeocacheViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/10/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import MapKit

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
            
            difficultyLabel.text = "Difficulty: " + String(format: "%.1f", cache.difficulty).capitalized
            
            usernameLabel.text = "Placed by: " + cache.placedBy
            dateLabel.text = "On: " + cache.getDateString()
        }
    }
    
    @IBAction func navigatePressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.navigationSegue, sender: self)
    }
    
    @IBAction func logPressed(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.navigationSegue {
            if let viewController = segue.destination as? NavigateViewController {
                viewController.destination = geocache?.location
                viewController.geocache = geocache
            }
        }
    }
}
