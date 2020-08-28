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
    static var channelColor: UIColor { return UIColor(named: "channelColor")! }
    static var sectionFont: UIColor { return UIColor(named: "sectionFont")! }
    
    static var sectionBackground: UIColor { return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7) }
    static var history: UIColor { return UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.7) }
    static var selected: UIColor { return UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1) }
    static var blueSelected: UIColor { return UIColor(red: 48/255, green: 123/255, blue: 246/255, alpha: 1) }
    static var highlighted: UIColor { return UIColor(red: 61/255, green: 134/255, blue: 246/255, alpha: 1) }

}

struct WeeklyCard {
    var title: String
    var source: String
    var category: String
    var time: Date
    var homeFormattedDate: String
    var color: String
    var url: String
    var json: [String: String]
    var formattedSource: String
}
