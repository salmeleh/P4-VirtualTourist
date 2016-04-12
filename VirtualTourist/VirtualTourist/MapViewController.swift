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
    
    var pins = [Pin]()
    
    let savedLonSpan = "Saved Longitude Span"
    let savedLatSpan = "Saved Latitude Span"
    let savedLat = "Saved Latitude"
    let savedLon = "Saved Longitude"
    var lon : Double = 0.0
    var lat : Double = 0.0
    var latDelta : Double = 0.0
    var lonDelta : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        initMap()
        
        //add gesture recognizer
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        //lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
        
        
        pins = fetchAllPins()
        
        self.mapView.delegate = self
    
    }

    
    //CORE DATA
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            print("Error in fetchAllActors(): \(error)")
            return [Pin]()
        }
    }
    
    
    
    //MAP SETUP & MKMapViewDelegate methods
    func initMap() {
        lonDelta = NSUserDefaults.standardUserDefaults().doubleForKey(savedLonSpan)
        latDelta = NSUserDefaults.standardUserDefaults().doubleForKey(savedLatSpan)
        lon = NSUserDefaults.standardUserDefaults().doubleForKey(savedLon)
        lat = NSUserDefaults.standardUserDefaults().doubleForKey(savedLat)
        
        if !(lat == 0 && lon == 0) {
            setRegion()
        }
    }
    
    func setRegion() -> MKCoordinateRegion {
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
        return region
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: savedLonSpan)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: savedLatSpan)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: savedLon)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: savedLat)
        
        initMap()
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            //pinView?.draggable = false
            //pinView?.pinTintColor = .Red
            
            let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
            pinView?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("showPAVC", sender: self)
        }
    }
    
    
    
    //long press gesture recognizer function
    //drops pin and adds annotation city
    func handleLongPress(gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        //reverse geocode the city for the pin annotation
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print(city)
                annotation.title = city as String
            }
                
            else {
                print("Problem with the data received from geocoder")
            }
        })
    
        
        //define/add dictionary for pin
        let dictionary: [String : AnyObject] = [
            "latitude" : touchMapCoordinate.latitude,
            "longitude" : touchMapCoordinate.longitude,
            ]
    
        let pin = Pin(dictionary: dictionary, context: CoreDataStackManager.sharedInstance().managedObjectContext)
    
        //add pin to the map
        mapView.addAnnotation(annotation)
        
        
        //download pictures
        if pin.photos.isEmpty {
            print("preloading photos")
            //getPhotosByLatLon
        }
        
        
        
        //save the context
        CoreDataStackManager.sharedInstance().saveContext()
    }

}

