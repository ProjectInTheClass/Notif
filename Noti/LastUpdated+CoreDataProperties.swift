//
//  LastUpdated+CoreDataProperties.swift
//  Noti
//
//  Created by sejin on 2020/06/12.
//  Copyright © 2020 Junroot. All rights reserved.
//
//

import Foundation
import CoreData


extension LastUpdated {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastUpdated> {
        return NSFetchRequest<LastUpdated>(entityName: "LastUpdated")
    }

    @NSManaged public var date: String?

}
