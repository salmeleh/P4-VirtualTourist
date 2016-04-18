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
    var selectedPin: Pin? = nil
    let locationManager = CLLocationManager()
    
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
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        initMap()
        mapView.showsUserLocation = true
        
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
        
        mapView.delegate = self
        restoreSavedPinsToMap()
        
        
    }

    
    func restoreSavedPinsToMap() {
        pins = fetchAllPins()
        
        for pin in pins {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.title
            mapView.addAnnotation(annotation)
        }
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
            print("Error in fetchAllPins(): \(error)")
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
        //get user location... maybe
        
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
        return region
    }
    
    //save new mapView if changed
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: savedLonSpan)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: savedLatSpan)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: savedLon)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: savedLat)
        
        initMap()
    }
    

    
    //gesture recognizer function
    //drops pin and adds annotation city
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        
        if getstureRecognizer.state != .Began {
            return
        }
        
        let touchPoint = getstureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        
        
       let newPin = Pin(lat: annotation.coordinate.latitude, lon: annotation.coordinate.longitude, context: sharedContext)
//        pins.append(newPin)
//        mapView.addAnnotation(annotation)
        
        //reverse geocode the city for the pin annotation
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

            //Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]

            if error != nil {
            print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }

            //City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                //print(city)
                annotation.title = city as String
            }
            
            //State
            if let state = placeMark.addressDictionary!["State"] as? NSString {
                //print(state)
                annotation.title = annotation.title! + ", " + (state as String)
            }

            else {
                print("Problem with the data received from geocoder")
            }
            
            newPin.title = annotation.title
            self.pins.append(newPin)
            CoreDataStackManager.sharedInstance().saveContext()
            
            
        })
        
        FlickrClient.sharedInstance().downloadPhotosForPin(newPin) { (success, error) in print("downloadPhotosForPin is success: \(success) - error: \(error)") }

        
        mapView.addAnnotation(newPin)       
        CoreDataStackManager.sharedInstance().saveContext()

        
    }
    
    
    //Map annotation functions
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
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
            
            let annotation = view.annotation
            let title = annotation!.title

            selectedPin = nil
            
            for pin in pins {
                if annotation!.coordinate.latitude == pin.latitude && annotation!.coordinate.longitude == pin.longitude {
                    selectedPin = pin
                    pin.title = title!
                    print(pin.title)
                    print("showPAVC")
                    self.performSegueWithIdentifier("showPAVC", sender: nil)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPAVC") {
            let viewController = segue.destinationViewController as! PhotoAlbumViewController
            viewController.pin = selectedPin
        }
    }

    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//    }
    
    

}

