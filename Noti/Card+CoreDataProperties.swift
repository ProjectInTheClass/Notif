//
//  Card+CoreDataProperties.swift
//  Noti
//
//  Created by sejin on 2020/06/05.
//  Copyright © 2020 Junroot. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var title: String?
    @NSManaged public var category: String?
    @NSManaged public var tag: [String]?
    @NSManaged public var channelName: String?
    @NSManaged public var time: Date?
    @NSManaged public var color: String?
    @NSManaged public var isVisited: Bool
    @NSManaged public var url: String?
    @NSManaged public var json: [String:String]?
    @NSManaged public var homeFormattedDate: String?
    @NSManaged public var historyFormattedDate: String?
    @NSManaged public var source: String?
    @NSManaged public var historyCardFormattedDate: String?

}
