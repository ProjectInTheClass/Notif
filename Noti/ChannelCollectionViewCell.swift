//
//  ChannelCollectionViewCell.swift
//  Noti
//
//  Created by sejin on 2020/05/28.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    var ChannelController = ChannelViewController()
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var channelCell: UIView!
    
    @IBOutlet weak var channelAlarmButton: UIButton!
    @IBOutlet weak var channelSubTitle: UILabel!
    @IBOutlet weak var channelColor: UIView!
    
    /*@IBAction func buttonTouched() {
        ChannelController.buttonTouched(self)
    }*/
    
     
}

class ChannelCollectionViewHeader: UICollectionReusableView{
    @IBOutlet weak var titleForChannelList: UILabel!
    
}
