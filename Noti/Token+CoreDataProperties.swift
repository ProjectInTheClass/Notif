//
//  Token+CoreDataProperties.swift
//  Noti
//
//  Created by sejin on 2020/07/27.
//  Copyright © 2020 Junroot. All rights reserved.
//
//

import Foundation
import CoreData


extension Token {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Token> {
        return NSFetchRequest<Token>(entityName: "Token")
    }

    @NSManaged public var name: String?

}
