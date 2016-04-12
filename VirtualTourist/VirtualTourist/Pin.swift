//
//  Pin.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/11/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import Foundation
import MapKit
import CoreData

@objc(Pin)
class Pin: NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    @NSManaged var latitude: CLLocationDegrees
    @NSManaged var longitude: CLLocationDegrees
    @NSManaged var photos: [Photo]
    
    
    //MKAnnotation needed variables
    var coordinate : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        latitude = dictionary[Keys.Latitude] as! CLLocationDegrees
        longitude = dictionary[Keys.Longitude] as! CLLocationDegrees
    }
    
    
}