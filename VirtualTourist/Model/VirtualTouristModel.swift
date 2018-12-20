//
//  VirtualTouristModel.swift
//  VirtualTourist
//
//  Created by Bhavya D J on 01/12/18.
//  Copyright © 2018 Bhavya D J. All rights reserved.
//

import Foundation

class VirtualTouristModel: NSObject {
    
    func taskForGETMethod(methodParameters: [String: String], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) {
        let request = NSURLRequest(url: flickrUrlFromParameter(methodParameters))
        let urlTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("Error could not complete GET request.")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Status code returned non-2XX code.")
                return
            }
            
            guard let data = data else {
                sendError("No data returned by request.")
                return
            }
            
            self.convertData(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        urlTask.resume()
    }
    
    func convertData(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        
        do {
            parsedResult = try JSONDecoder().decode(Constants.PhotoResults.self, from: data) as AnyObject
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertData", code: 1, userInfo: userInfo))
            return
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    func flickrUrlFromParameter(_ parameters: [String: String]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

}
