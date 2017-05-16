//
//  LocationCellTableViewCell.swift
//  Location_Collection
//
//  Created by Krishan Sunil Premaretna on 27/4/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit

class LocationCellTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    static let identifier = "LocationCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(location : Location){
        self.timeLabel.text = location.collectedtimehumanreadable
        self.latitudeLabel.text = "\(location.latitude)"
        self.longitudeLabel.text = "\(location.longitude)"
    }
    
}
