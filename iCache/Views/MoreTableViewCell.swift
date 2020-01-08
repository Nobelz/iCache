//
//  MoreTableViewCell.swift
//  iCache
//
//  Created by Nobel Zhou on 1/7/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
