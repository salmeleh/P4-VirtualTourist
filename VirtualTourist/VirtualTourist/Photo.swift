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
        static let photoURL = "photoURL"
        static let ID = "id"
        static let Name = "title"
    }
    
    @NSManaged var pin: Pin?
    @NSManaged var photoURL: String?
    @NSManaged var id: Double
    @NSManaged var name: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(photoURL: String, pin: Pin, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.photoURL = photoURL
        self.pin = pin
        
    }
    
    
}
