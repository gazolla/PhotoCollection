//
//  Photo.swift
//  PhotoCollection
//
//  Created by Gazolla on 05/07/16.
//  Copyright © 2016 Gazolla. All rights reserved.
//

import Foundation

public class Photo {
    
    var id:String?
    var imgUrl:String?
    var owner:String?
    var title:String?
    
    convenience required public init(attrib:[String:AnyObject]){
        self.init(id:attrib["id"]! as! String, imgUrl:attrib["url_m"]! as! String, owner:attrib["owner"]! as! String, title:attrib["title"]! as! String)
    }
    
    init(id:String, imgUrl:String, owner:String, title:String){
        self.id = id
        self.imgUrl = imgUrl
        self.owner = owner
        self.title = title
    }
    
    init(){}

    static func load(completion:(error:NSError?, items:[Photo]?)->Void){
        
        let apiKey = "INSERT_YOUR_API_KEY_HERE"
        let userid = "24858431@N07"
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=\(apiKey)&user_id=\(userid)&extras=url_m&format=json&nojsoncallback=1"

        
        HTTP.GET(urlString) { (error, data) in
            var its = [Photo]()
            if error != nil {
                completion(error: error, items: nil)
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                if let photos = json["photos"] as? [String:AnyObject]{
                    if let photo = photos["photo"] as? [AnyObject]{
                        for ph in photo {
                            its.append(Photo(attrib: ph as! [String : AnyObject]))
                        }
                    }
                } else {
                    if (json["stat"] as? String) != nil {
                        if let code = json["code"] as? Int {
                            if let message = json["message"] as? String{
                                let er = NSError(domain: "flickr", code: code, userInfo: [NSLocalizedDescriptionKey:message])
                                completion(error: er, items: nil)
                                return
                            }
                        }
                    }
                }
                
                completion(error: nil, items: its)
            } catch let er as NSError {
                completion(error: er, items: nil)
            }
        }
    }

    
}

extension Photo:CustomStringConvertible {
    public var description:String {
        var s = "["
        if let id = self.id { s += "id: \(id), \n" }
        if let imgUrl = self.imgUrl { s += "id: \(imgUrl), \n" }
        if let owner = self.owner { s += "id: \(owner), \n" }
        if let title = self.title { s += "id: \(title)] \n" }
        
        return s
    }
}
