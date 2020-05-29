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
    static var navBack: UIColor { return UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1) }
        static var navFont: UIColor { return UIColor(red: 27/255, green: 26/255, blue: 29/255, alpha: 1) }
        static var sourceFont: UIColor { return UIColor(red: 190/255, green: 191/255, blue: 195/255, alpha: 1) }
}

class Card {
    var title: String
    var source: String?
    var tag = [String]()
    var time: Date
    var color: UIColor
    var isVisited = false
    var url: String
    var json = [String:String]()
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.string(from: time)
    }
    
    
    init(title: String, source: String? = nil, tag:[String] = [String](), time: Date, color: UIColor, isVisited:Bool = false, url: String, json: [String:String] = [String:String]() ){
        self.title = title
        self.source = source
        self.tag = tag
        self.time = time
        self.color = color
        self.isVisited = isVisited
        self.url = url
        self.json = json
    }
}
struct Channel {
    var title: String
    var category: String
    var channelTags = [String]()
    //static var allTags = [Tag]()
    var isSubscribed : Bool = false
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
