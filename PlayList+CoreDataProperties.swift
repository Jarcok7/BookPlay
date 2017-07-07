//
//  PlayList+CoreDataProperties.swift
//  BookPlay
//
//  Created by Jarco Katsalay on 6/16/17.
//  Copyright © 2017 Jarco Katsalay. All rights reserved.
//

import Foundation
import CoreData


extension PlayList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayList> {
        return NSFetchRequest<PlayList>(entityName: "PlayList")
    }

    @NSManaged public var timestamp: NSDate
    @NSManaged public var name: String

}
