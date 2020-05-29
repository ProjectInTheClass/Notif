//
//  tagTableViewCell.swift
//  Noti
//
//  Created by sejin on 2020/05/19.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class tagTableViewCell: UITableViewCell {

    
    @IBOutlet weak var whenTagCreated: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
