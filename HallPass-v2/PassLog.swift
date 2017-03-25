//
//  PassLog.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/22/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit

class PassLog: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
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
