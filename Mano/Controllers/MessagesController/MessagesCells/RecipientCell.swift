//
//  RecipientCell.swift
//  Mano
//
//  Created by Leandro Wauters on 8/21/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class RecipientCell: UITableViewCell {

    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}