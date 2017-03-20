//
//  StudentCell.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/18/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {

    @IBOutlet weak var studentNameLabel: UILabel!

    @IBOutlet weak var attsLabel: UILabel!
    var student: Student!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
