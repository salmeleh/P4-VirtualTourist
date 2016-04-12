//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/12/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {
    var session: NSURLSession
    
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
    
    //HELPER METHODS
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    static let methodArguments: [String: String!] = [
        "method": FlickrClient.Constants.METHOD_NAME,
        "api_key": FlickrClient.Constants.API_KEY,
        "safe_search": FlickrClient.Constants.SAFE_SEARCH,
        "extras": FlickrClient.Constants.EXTRAS,
        "format": FlickrClient.Constants.DATA_FORMAT,
        "nojsoncallback": FlickrClient.Constants.NO_JSON_CALLBACK,
        "per_page" : "21",
        ]





}