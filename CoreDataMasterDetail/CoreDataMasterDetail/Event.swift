//
//  Event.swift
//  CoreDataMasterDetail
//
//  Created by Jason on 3/9/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {

    @NSManaged var timeStamp: NSDate

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Event", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        timeStamp = NSDate()
    }
}
