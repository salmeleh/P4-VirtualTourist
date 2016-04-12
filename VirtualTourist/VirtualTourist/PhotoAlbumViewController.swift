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
    
        mapView.delegate = self
        loadMapView()
        
        
    }
    
    //CORE DATA
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photos")
        
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()

    
    
    func loadMapView() {
        let sentPin = MKPointAnnotation()
        sentPin.coordinate = CLLocationCoordinate2DMake((pin!.latitude), (pin!.longitude))
        sentPin.title = pin?.title
        
        mapView.addAnnotation(sentPin)
        
        mapView.centerCoordinate = sentPin.coordinate
        mapView.selectAnnotation(sentPin, animated: true)
    }

    
    
    
    
    
    
    
    @IBAction func bottomBarButtonPressed(sender: AnyObject) {
    }
    
        

}
