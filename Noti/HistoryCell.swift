//
//  HIstoryCell.swift
//  Noti
//
//  Created by 이상윤 on 2020/06/03.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var backLine: UIImageView!
    @IBOutlet weak var history: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
