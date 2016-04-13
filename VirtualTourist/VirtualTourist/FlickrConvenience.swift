//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/13/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import UIKit
import CoreData

extension FlickrClient {
    
    func downloadPhotosForPin(pin: Pin, completionHandler: (success: Bool, error: NSError?) -> Void) {
        //RANDOM PAGE
        var randomPageNumber: Int = 1
        if let numberPages = pin.pageNumber?.integerValue {
            if numberPages > 0 {
                let pageLimit = min(numberPages, 20)
                randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1 }
        }
        
        //PARAMETERS
        let parameters: [String : AnyObject] = [
            URLKeys.Method : Methods.Search,
            URLKeys.APIKey : Constants.APIKey,
            URLKeys.Format : URLValues.JSONFormat,
            URLKeys.NoJSONCallback : 1,
            URLKeys.Latitude : pin.latitude,
            URLKeys.Longitude : pin.longitude,
            URLKeys.Extras : URLValues.URLMediumPhoto,
            URLKeys.Page : randomPageNumber,
            URLKeys.PerPage : 21
        ]
        
        //Make GET request
        taskForGETMethodWithParameters(parameters, completionHandler: {
            results, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                
                //Response
                if let photosDictionary = results.valueForKey(JSONResponseKeys.Photos) as? [String: AnyObject],
                    photosArray = photosDictionary[JSONResponseKeys.Photo] as? [[String : AnyObject]],
                    numberOfPhotoPages = photosDictionary[JSONResponseKeys.Pages] as? Int {
                    
                    pin.pageNumber = numberOfPhotoPages
                    
                    self.numberOfPhotosDownloaded = photosArray.count
                    
                    // DictionarY
                    for photoDictionary in photosArray {
                        
                        guard let photoURLString = photoDictionary[URLValues.URLMediumPhoto] as? String else {
                            print ("error, photoDictionary)"); continue}
                        
                        let newPhoto = Photo(photoURL: photoURLString, pin: pin, context: self.sharedContext)
                        
                        self.downloadPhotoImage(newPhoto, completionHandler: {
                            success, error in
                            
                            print("Downloading photo by URL - \(success): \(error)")
                            
                            self.numberOfPhotosDownloaded -= 1

                            NSNotificationCenter.defaultCenter().postNotificationName("downloadPhotoImage.done", object: nil)
                            
                            // Save the context
                            dispatch_async(dispatch_get_main_queue(), {
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                        })
                    }
                    
                    completionHandler(success: true, error: nil)
                    
                } else {
                    //ERROR
                    completionHandler(success: false, error: NSError(domain: "downloadPhotosForPin", code: 0, userInfo: nil))
                
                }
            }
        })
    }

    
    
    func downloadPhotoImage(photo: Photo, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let imageURLString = photo.photoURL
        
        // Make GET request for download photo by url
        taskForGETMethod(imageURLString!, completionHandler: {
            result, error in
            
            // If there is an error - set file path to error to show blank image
            if let error = error {
                print("Error from downloading images \(error.localizedDescription )")
                photo.photoURL = "error"
                completionHandler(success: false, error: error)
                
            } else {
                
                if let result = result {
                    
                    // Get file name and file url
                    let fileName = (imageURLString! as NSString).lastPathComponent
                    let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                    let pathArray = [dirPath, fileName]
                    let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
                    //print(fileURL)
                    
                    // Save file
                    NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: result, attributes: nil)
                    
                    // Update the Photos model
                    photo.photoURL = fileURL.path
                    
                    completionHandler(success: true, error: nil)
                }
            }
        })
    }

    
    
    
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    
    
    
    
    
}