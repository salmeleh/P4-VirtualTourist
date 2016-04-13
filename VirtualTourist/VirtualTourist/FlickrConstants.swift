//
//  NetworkingConvenience.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/11/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

extension FlickrClient {

    struct Constant {
        static let baseURL = "https://api.flickr.com/services/rest/"
        static let ApiKey = "3cf0014e24ba656dc214ea5cf81789b9"
        static let Safesearch = "1"
        static let Extras = "url_m"
        static let DataFormat = "json"
        static let No_JSON_CALLBACK = "1"
        static let photosPerPage = 24
    }
    
    //MARK:- Flickr methods to download data
    struct Methods {
        static let SearchPhotosbyLatLon = "flickr.photos.search"
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Safesearch = "safe_search"
        static let Extras = "extras"
        static let Dataformat = "format"
        static let NOJSONCallback = "nojsoncallback"
        static let pageNumber = "page"
        static let photosPerPage = "per_page"
        
    }
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let TotalPages = "pages"
        static let Photo = "photo"
        static let Message = "msg"
        
    }

}