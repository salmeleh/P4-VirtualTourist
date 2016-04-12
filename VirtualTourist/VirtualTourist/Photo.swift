//
//  Photo.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/11/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Photo: NSManagedObject {
    
    struct Keys {
        static let urlPath = "urlPath"
        static let ID = "id"
        static let Name = "title"
    }
    
    @NSManaged var pin: Pin?
    @NSManaged var urlPath: String?
    @NSManaged var id: Double
    @NSManaged var name: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        urlPath = dictionary[Keys.urlPath] as? String
        id = Double((dictionary[Keys.ID] as? String)!)!
        name = dictionary[Keys.Name] as! String
    }
    
    
}
