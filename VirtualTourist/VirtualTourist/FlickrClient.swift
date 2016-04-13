//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/12/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class FlickrClient : NSObject {
    
    var session: NSURLSession
    var numberOfPhotosDownloaded = 0
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //SHARED INSTANCE
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    //TASK FOR GET METHOD
    func taskForGETMethodWithParameters(parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        print("taskForGETMethodWithParameters")
        //Build the URL and configure the request
        let urlString = Constants.BaseURL + escapedParameters(parameters)
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        //Make the request
        let task = session.dataTaskWithRequest(request) {
            data, response, downloadError in
            
            //Parse the received data
            if let error = downloadError {
                let newError = FlickrClient.errorFromParsed(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        //Start the request
        task.resume()
    }
    
    
    func taskForGETMethod(urlString: String,completionHandler: (result: NSData?, error: NSError?) -> Void) {
        print("taskForGETMethod")
        //Configure the request
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        //Make the request
        let task = session.dataTaskWithRequest(request) {
            data, response, downloadError in
            
            //Parse the received data
            if let error = downloadError {
                let newError = FlickrClient.errorFromParsed(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                completionHandler(result: data, error: nil)
            }
        }
        
        // Start the request
        task.resume()
    }
    
    
    
    
    
    //PARSE & RETURN ERROR
    class func errorFromParsed(data:NSData?, response:NSURLResponse?, error:NSError) -> NSError {
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String:AnyObject] {
            if let errorMessage = parsedResult[JSONResponseKeys.Message] as? String {
                let userInfo = [NSLocalizedDescriptionKey: errorMessage]
                return NSError(domain: "VirtualTourist Error", code: 1, userInfo: userInfo)
            }
        }
        return error
    }
    
    
    //PARSE JSON RESPONSE
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler:(result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    
    //HELPER METHOD
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }





}