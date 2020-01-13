//
//  ProfileViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/8/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseUI
import CoreLocation

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var geocachesFoundLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()

    var user: Profile?
    var logs: [Log]?
//    var selectedLog: Log?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: K.logCellNibName, bundle: nil), forCellReuseIdentifier: K.logCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logs = nil
        
        let usersRef = Firestore.firestore().collection("users")
        let storageRef = Storage.storage().reference()
        
        usersRef.whereField("email", isEqualTo: Auth.auth().currentUser!.email!)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        let email = data["email"] as! String
                        let profilePicURL = data["profilePic"] as! String
                        let joinDate = data["joinDate"] as! String
                        let geocachesFound = data["geocachesFound"] as! Int
                        let username = data["username"] as! String
                        if let log = data["log"] as? String {
                            self.logs = Log.parseLog(log: log)
                        }
                        
                        self.user = Profile(email: email, profilePicURL: profilePicURL, joinDate: joinDate, geocachesFound: geocachesFound, username: username)
                        
                        let reference = storageRef.child(self.user!.profilePicURL)
                        self.profileImageView.sd_setImage(with: reference)
                        
                        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                        self.profileImageView.clipsToBounds = true
                        
                        self.dateCreatedLabel.text = "Joined: " + self.user!.joinDate
                        self.geocachesFoundLabel.text = "\(self.user!.geocachesFound) Found"
                        
                        self.usernameLabel.text = self.user!.username.capitalized
                        
                        self.tableView.reloadData()
                    }
                }
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if logs != nil {
            return logs!.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.logCellIdentifier, for: indexPath) as! ProfileTableViewCell
        
        if logs != nil {
            let log = logs![indexPath.row]
            
            if log.isSuccess {
                cell.iconImageView.image = UIImage(systemName: "checkmark.seal")
                cell.iconImageView.tintColor = UIColor.green
                
                cell.statusLabel.text = "Found"
            } else {
                cell.iconImageView.image = UIImage(systemName: "xmark")
                cell.iconImageView.tintColor = UIColor.red
                
                cell.statusLabel.text = "Not Found"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: log.date))
            
            cell.dateLabel.text = "Date: " + dateString
            cell.idLabel.text = "Geocache #" + log.id
            
            return cell
        } else {
            cell.iconImageView.image = UIImage(systemName: "magnifyingglass")
            cell.idLabel.text = "No geocaches logged. Go log some!"
            
            return cell
        }
    }
}

//COMING SOON

//extension ProfileViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if logs != nil {
//            selectedLog = logs![indexPath.row]
//
//            performSegue(withIdentifier: K.Segues.logClickedSegue, sender: self)
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == K.Segues.logClickedSegue {
//            if let viewController = segue.destination as? GeocacheViewController, let log = selectedLog {
//                let docRef = db.collection("geocaches").document(log.id)
//
//                docRef.getDocument { (document, error) in
//                    if let document = document, document.exists {
//                        let data = document.data()!
//
//                        let username = data["placedBy"] as! String
//                        let name = data["name"] as! String
//                        let date = data["datePlaced"] as! Double
//                        let datePlaced = Date(timeIntervalSince1970: date)
//                        let difficulty = data["difficulty"] as! Double
//                        let locationGeopoint = data["location"] as! GeoPoint
//                        let location = CLLocation(latitude: CLLocationDegrees(exactly: locationGeopoint.latitude)!, longitude: CLLocationDegrees(exactly: locationGeopoint.longitude)!)
//                        let numberOfFinds = data["numberOfFinds"] as! Int
//                        let hint1 = data["hint1"] as! String
//                        let hint2 = data["hint2"] as! String
//                        let hints = [hint1, hint2]
//                        let id = document.documentID
//
//                        let geocache = Geocache(name: name, placedBy: username, datePlaced: datePlaced, difficulty: difficulty, location: location, numberOfFinds: numberOfFinds, hints: hints, id: id)
//
//                        viewController.geocache = geocache
//                    }
//                }
//            }
//        }
//    }
//}
