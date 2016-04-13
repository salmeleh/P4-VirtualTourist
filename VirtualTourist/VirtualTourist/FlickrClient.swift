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
    
    //TASK FOR GET METHOD
    func taskForGETMethod(parameters: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Set the parameters
        let mutableParameters = parameters
        
        //Build URL and configure Request
        let urlString = Constant.baseURL  + escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        //Make the Request
        let task = session.dataTaskWithRequest(request) {data,response,downloadError in
            //Parse the data and use the data
            if let error = downloadError {
                let newError = FlickrClient.errorFromParsed(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                FlickrClient.parseJSONWithmpletionHandler(data!, completionHandler: completionHandler)
            }
        }
        // Start the request
        task.resume()
        return task
        
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
    class func parseJSONWithmpletionHandler(data: NSData, completionHandler:(result: AnyObject!, error: NSError?) -> Void) {
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