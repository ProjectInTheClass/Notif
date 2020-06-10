//
//  Tags+CoreDataProperties.swift
//  Noti
//
//  Created by sejin on 2020/06/05.
//  Copyright © 2020 Junroot. All rights reserved.
//
//

import Foundation
import CoreData


extension Tags {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tags> {
        return NSFetchRequest<Tags>(entityName: "Tags")
    }

    @NSManaged public var name: String?
    @NSManaged public var time: Date?
    @NSManaged public var formattedDate: String?

}
