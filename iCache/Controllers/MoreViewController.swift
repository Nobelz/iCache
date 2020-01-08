//
//  MoreViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/7/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase

class MoreViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: K.moreCellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
    }
}

extension MoreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MoreTableViewCell
        
        cell.descriptionLabel.text = "Log Out"
        cell.cellImage.image = UIImage(systemName: "square.and.arrow.up")
        
        return cell
    }
}

extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        if index == 0 {
            let alertController = UIAlertController(title: "Are You Sure?", message: "Are you sure you want to sign out?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                do {
                    try Auth.auth().signOut()
                    self.navigationController?.popToRootViewController(animated: true)
                } catch {
                    print(error)
                }
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            present(alertController, animated: true)
        }
    }
}
