//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/11/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadingWheel.hidesWhenStopped = true
        // set initial location in Chicago
        let initialLocation = CLLocation(latitude: 41.881832, longitude: -87.623177)
        centerMapOnLocation(initialLocation)
        
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        //lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
        
        
        // Step 2: invoke fetchedResultsController.performFetch(nil) here
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        
        self.mapView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()


    //MKMapViewDelegate methods
    
    
    
    //long press gesture function
    func handleLongPress(gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        mapView.addAnnotation(annotation)
    }
    
    
    
    
    //radius helper
    let regionRadius: CLLocationDistance = 10000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

