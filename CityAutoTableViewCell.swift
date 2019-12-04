//
//  CityAutoTableViewCell.swift
//  Weather
//
//  Created by Ouyu Lan on 11/30/19.
//  Copyright © 2019 Ouyu Lan. All rights reserved.
//

import UIKit

class CityAutoTableViewCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
