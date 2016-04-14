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

class PhotoAlbumViewController : UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    var selectedIndexofCollectionViewCells = [NSIndexPath]()
    
    
    //CORE DATA
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mapView.delegate = self
        loadMapView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Perform the fetch
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("\(error)")
        }

        fetchedResultsController.delegate = self
        
        
    }
    
    
    
    //load in sent pin
    func loadMapView() {
        let sentPin = MKPointAnnotation()
        sentPin.coordinate = CLLocationCoordinate2DMake((pin?.latitude)!, (pin?.longitude)!)
        sentPin.title = pin?.title
        
        mapView.addAnnotation(sentPin)
        
        mapView.centerCoordinate = sentPin.coordinate
        mapView.selectAnnotation(sentPin, animated: true)
        
        
    }

    //COLLECTION VIEW METHODS
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("# of photos returned from fetchedResultsController: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo

        cell.imageView.image = photo.image

        return cell
    }
    
    
    
    
    @IBAction func bottomBarButtonPressed(sender: AnyObject) {
    }
    
        

}
