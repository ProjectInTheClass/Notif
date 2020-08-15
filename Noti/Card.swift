//
//  Card.swift
//  Noti
//
//  Created by Junroot on 2020/05/17.
//  Copyright © 2020 Junroot. All rights reserved.
//

import Foundation
import UIKit

/*enum cardType {
    case tag, card
}*/

extension UIColor {
    class func color(data:Data) -> UIColor? {
         return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
    func encode() -> Data? {
         return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    

    
    static var first: UIColor  { return UIColor(red: 205/255, green: 98/255, blue: 94/255, alpha: 1) }
    static var second: UIColor { return UIColor(red: 218/255, green: 147/255, blue: 94/255, alpha: 1) }
    static var third: UIColor { return UIColor(red: 108/255, green: 166/255, blue: 94/255, alpha: 1) }
    static var fourth: UIColor { return UIColor(red: 95/255, green: 142/255, blue: 199/255, alpha: 1) }
    static var fifth: UIColor { return UIColor(red: 54/255, green: 81/255, blue: 113/255, alpha: 1) }
    static var navBack: UIColor { return UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1) }
    static var navFont: UIColor { return UIColor(named: "navFont")! }
    static var cardFront: UIColor { return UIColor(named: "cardFront")! }
    static var cardBack: UIColor { return UIColor(named: "cardBack")! }
    static var sourceFont: UIColor { return UIColor(named: "unselectedFont")! }
    static var sectionFont: UIColor { return UIColor(red: 84/255, green: 88/255, blue: 94/255, alpha: 1) }
    static var sectionBackground: UIColor { return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7) }
    static var history: UIColor { return UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.7) }
    static var selected: UIColor { return UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1) }
    static var blueSelected: UIColor { return UIColor(red: 48/255, green: 123/255, blue: 246/255, alpha: 1) }
    static var highlighted: UIColor { return UIColor(red: 61/255, green: 134/255, blue: 246/255, alpha: 1) }

}

/*class Card {
    var title: String
//    var source: String?
    var category: String
    var channelName: String
    var tag = [String]()
    var time: Date
    var color: UIColor
    var isVisited = false
    var url: String
    var json = [String:String]()
    
    var homeFormattedDate: String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // 임시로 보여주기 위해 선언함
        let now = dateFormatter.date(from: "2020-05-18")!
        //
        let standard = dateFormatter.string(from: now)
        let result = dateFormatter.string(from: time)
        dateFormatter.dateFormat = "HH:mm"
        if result == standard{
            return "오늘 " + dateFormatter.string(from: time)
        }else{
            return "어제 " + dateFormatter.string(from: time)
        }
    }
    
    var historyFormattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M.d"
        return dateFormatter.string(from: time)
    }
    
    var historyCardFormattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: time)
    }
    
    var source: String{
        return category+channelName
    }
    
    
    init(title: String, channelName: String, category: String, tag:[String] = [String](), time: Date, color: UIColor, isVisited:Bool = false, url: String, json: [String:String] = [String:String]() ){
        self.title = title
        self.channelName = channelName
        self.category = category
        self.tag = tag
        self.time = time
        self.color = color
        self.isVisited = isVisited
        self.url = url
        self.json = json
    }
}
class Channel {
    var title: String
    var subtitle: String
    var category: String
    var source: String
    var color: UIColor
    var channelTags = [String]()
    var alarm = false
    //static var allTags = [Tag]()
    var isSubscribed : Bool = false
    
    init(title: String, subtitle: String, category: String, source: String, color: UIColor, channelTags: [String] = [String](), alarm: Bool = false, isSubscribed:Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.source = source
        self.color = color
        self.channelTags = channelTags
        self.alarm = alarm
        self.isSubscribed = isSubscribed
    }
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

}*/
