//
//  ChannelCollectionViewCell.swift
//  Noti
//
//  Created by 이상윤 on 2020/06/05.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var channelCell: UIView!
    
    @IBOutlet weak var channelAlarmButton: UIButton!
    @IBOutlet weak var channelSubTitle: UILabel!
    @IBOutlet weak var channelColor: UIView!
    
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var notificationButton: UIButton!
    
    var indexPath: IndexPath = []
    var isButtonEnabled = false
    /*@IBAction func buttonTouched() {
        ChannelController.buttonTouched(self)
    }*/
    
     
}

class ChannelCollectionViewHeader: UICollectionReusableView{
    @IBOutlet weak var titleForChannelList: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    
}
