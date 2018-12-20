//
//  VirtualTouristConstants.swift
//  VirtualTourist
//
//  Created by Bhavya D J on 01/12/18.
//  Copyright © 2018 Bhavya D J. All rights reserved.
//

import Foundation

extension VirtualTouristModel {
    //MARK: Constants
    struct Constants {
        
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
            
        }
        // MARK: Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let method = "method"
            static let apiKey = "api_key"
            static let format = "format"
            static let authToken = "auth_token"
            static let apiSig = "api_sig"
            static let latitude = "lat"
            static let longitude = "lon"
        }
        
        // MARK: Flickr Parameter Values
        struct FlickrParameterValues {
            static let apiKey = "5fadaf711282aa60cada92ae52cc8137"
            static let responseFormat = "json"
        }
        
        // MARK: Codable structs to be used in parsing json data
        struct PhotoResults: Decodable {
            var photos: Photos?
            var stat: String?
        }
        
        struct Photos: Decodable {
            var page: Int?
            var pages: Int?
            var perpage: Int?
            var total: String?
            var photo: [pinPhoto]?
        }
        
        struct pinPhoto: Decodable {
            var id: String?
            var owner: String?
            var secret: String?
            var server: String?
            var farm: Int?
            var title: String?
            var ispublic: Int?
            var isfriend: Int?
            var isfamily: Int?
        }
        
        // MARK: Flickr Response Keys photosForLocation
        struct FlickrPhotosForLocationResponseKeys: Decodable {
            static let photos = "photos"
            
            // Response keys for the photo objects in the array
            static let photo = "photo"
            static let id = "id"
            static let owner = "owner"
            static let secret = "secret"
            static let server = "server"
            static let farm = "farm"
            static let title = "title"
            static let isPublic = "ispublic"
            static let isFriend = "isfriend"
            static let isFamily = "isfamily"
        }
        
        struct FlickrPhotosForLocationResponseKeysPhotos: Decodable {
            static let page = "page"
            static let pages = "pages"
            static let perPage = "perpage"
            static let total = "total"
        }
        
        
        //MARK: Flickr API Key
        static let ApiKey = "5fadaf711282aa60cada92ae52cc8137"
        
        //MARK: Methods
        struct Methods {
            static let photoSearchUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(VirtualTouristModel.Constants.ApiKey)&format=json&nojsoncallback=1"
        }
    }
    
    // MARK: Singleton
    class func sharedInstance() -> VirtualTouristModel {
        struct Singleton {
            static var sharedInstance = VirtualTouristModel()
        }
        return Singleton.sharedInstance
    }
}
