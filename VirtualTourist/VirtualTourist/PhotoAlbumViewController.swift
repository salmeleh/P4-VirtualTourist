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
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImageLabel: UILabel!
    
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
        newCollectionButton.hidden = true
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadPhotos:", name: "downloadPhotoImage.done", object: nil)
    }
    

    func reloadPhotos(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
            
            let numberRemaining = FlickrClient.sharedInstance().numberOfPhotosDownloaded
            print("numberRemaining from reloadPhotos: \(numberRemaining)")
            if numberRemaining <= 0 {
                self.newCollectionButton.hidden = false
            }
        })
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
        let numberItems = sectionInfo.numberOfObjects
        print("# of photos returned from fetchedResultsController: \(numberItems)")
        
        if (numberItems > 0) {
            newCollectionButton.hidden = false
        }
        if (numberItems == 0) {
            noImageLabel.hidden = true
        }
        
        return numberItems
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo

        cell.imageView.image = photo.image
        
        return cell
    }
    
    
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController")
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func bottomBarButtonPressed(sender: AnyObject) {
        newCollectionButton.hidden = true
        
        //delete pics
        for photo in fetchedResultsController.fetchedObjects as! [Photo]{
            sharedContext.deleteObject(photo)
        }
        
        //save core data
        CoreDataStackManager.sharedInstance().saveContext()

        //re-download
        FlickrClient.sharedInstance().downloadPhotosForPin(pin!, completionHandler: {
            success, error in
            
            if success {
                //save CD
                dispatch_async(dispatch_get_main_queue(), {
                    CoreDataStackManager.sharedInstance().saveContext()
                })
            } else {
                //error
                dispatch_async(dispatch_get_main_queue(), {
                    print("error downloading a new set of photos")
                    self.newCollectionButton.hidden = true
                })
            }
            //re-fetch & reload
            dispatch_async(dispatch_get_main_queue(), {
                do {
                    try self.fetchedResultsController.performFetch()
                } catch let error as NSError {
                    print("\(error)")
                }
            })
            
        })

        
        
    }
    
    

}
