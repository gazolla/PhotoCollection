//
//  HTTP.swift
//  TableTest4
//
//  Created by Gazolla on 05/07/16.
//  Copyright © 2016 Gazolla. All rights reserved.
//

import UIKit

public class HTTP{
    
    static func GET(urlString:String, completion:(error:NSError?, data:NSData?)->Void){
        if let request = NSMutableURLRequest(urlString: urlString, method: .GET){
            connectToServer(request, completion: completion)
        } else {
            throwError(400, completion: completion)
        }
    }
    
    static func connectToServer(request:NSMutableURLRequest, completion:(error:NSError?, data:NSData?)->Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        session.dataTaskWithRequest(request) { (data, response, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                completion(error: error, data: nil)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if 200...299 ~= httpResponse.statusCode {
                    completion(error: nil, data: data)
                } else {
                    throwError(httpResponse.statusCode, completion: completion)
                }
            }
        }.resume()
    }
    
    static func throwError(code:Int, completion:(error:NSError?, data:NSData?)->Void){
        let er = NSError(domain: "com.gazapps", code: code, userInfo: [NSLocalizedDescriptionKey:NSHTTPURLResponse.localizedStringForStatusCode(code)])
        completion(error: er, data: nil)
    }
}

extension NSMutableURLRequest {
    public convenience init?(urlString:String, method:HTTPVerb, body:NSData?=nil){
        if let url = NSURL(string: urlString) {
            self.init(URL:url)
            self.addValue("application/json", forHTTPHeaderField: "Content-type")
            self.addValue("application/json", forHTTPHeaderField: "Accept")
            self.HTTPBody = body
            self.HTTPMethod = method.rawValue
        } else {
            return nil
        }
    }
}

public enum HTTPVerb:String {
    case GET
    case POST
    case PUT
    case DELETE
}