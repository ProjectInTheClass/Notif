//
//  Card.swift
//  Noti
//
//  Created by Junroot on 2020/05/17.
//  Copyright © 2020 Junroot. All rights reserved.
//

import Foundation
import UIKit

enum cardType {
    case tag, card
}

extension UIColor {
    static var first: UIColor  { return UIColor(red: 205/255, green: 98/255, blue: 94/255, alpha: 1) }
    static var second: UIColor { return UIColor(red: 218/255, green: 147/255, blue: 94/255, alpha: 1) }
    static var third: UIColor { return UIColor(red: 108/255, green: 166/255, blue: 94/255, alpha: 1) }
    static var fourth: UIColor { return UIColor(red: 95/255, green: 142/255, blue: 199/255, alpha: 1) }
    static var fifth: UIColor { return UIColor(red: 54/255, green: 81/255, blue: 113/255, alpha: 1) }
}

struct Card {
    var title: String
    var source: String?
    var tag = [String]()
    var time: Date
    var color: UIColor
    var isVisited: Bool = false
    var url: String
    var json = [String:String]()
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: time)
    }
}

struct Channel {
    var title: String
    //var subTitle: String?
    var channelTags = [String]()
    static var allTags = [Tag]()
    //channeltag -> string alltag -> tag
}

struct Tag {
    var name: String
    var time: Date
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: time)
    }
}
