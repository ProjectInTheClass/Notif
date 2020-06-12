//
//  Channel+CoreDataProperties.swift
//  Noti
//
//  Created by sejin on 2020/06/05.
//  Copyright © 2020 Junroot. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }
    
    @NSManaged public var title: String?
    @NSManaged public var subtitle: String?
    @NSManaged public var category: String?
    @NSManaged public var color: String?
    @NSManaged public var channelTags: [String]?
    @NSManaged public var alarm: Bool
    @NSManaged public var isSubscribed: Bool
    @NSManaged public var source : String?
}
