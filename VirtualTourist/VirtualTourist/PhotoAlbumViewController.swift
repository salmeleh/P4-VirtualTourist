//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/11/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController : UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    var pin: Pin? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    //CORE DATA
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Create fetch request for photos which match the sent Pin.
        let fetchRequest = NSFetchRequest(entityName: "Photos")
        
        // Limit the fetch request to just those photos related to the Pin.
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        
        // Sort the fetch request by title, ascending.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        // Create fetched results controller with the new fetch request.
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()

    
    
    
    @IBAction func bottomBarButtonPressed(sender: AnyObject) {
    }
    
        

}
