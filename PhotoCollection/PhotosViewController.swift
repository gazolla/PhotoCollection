//
//  MainViewController.swift
//  PhotoCollection
//
//  Created by Gazolla on 23/01/16.
//  Copyright © 2016 Gazolla. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView:UICollectionView?
    var layout:UICollectionViewFlowLayout?
    var items:[String]=[]
    
    
    //PRAGMA MARK: Setup Methods
    func setupCollectionView() {
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.layout!)
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        self.collectionView!.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView!.registerClass(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        
        self.view.addSubview(self.collectionView!)
    }
    
    func setupLayout(){
        self.layout = UICollectionViewFlowLayout()
        self.layout!.sectionInset = UIEdgeInsetsMake(2.0,20.0,2.0,20.0)
    }

    //PRAGMA MARK: UICollectionViewDataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    //PRAGMA MARK: UICollectionViewDelegate Methods
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PhotoCell
        
        let imageName = self.items[indexPath.row]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageName)!)!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let myCell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell {
                    myCell.imageView.image = image
                }
            })
        }
        
         return cell
    }
    
    //PRAGMA MARK: UICollectionViewDelegateFlowLayout Methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.bounds.width
        let cellSide = (width / 2) - 40
        return CGSizeMake(cellSide, cellSide)
    }
    
    //PRAGMA MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Flickr Photos"
        self.setupLayout()
        self.setupCollectionView()
        self.processJSON()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //PRAGMA MARK: Business Method
    func processJSON(){
        
        // use the explore flickr web page to generate your url
        // https://www.flickr.com/services/api/explore/flickr.people.getPublicPhotos
        
        let apiKey = "a99b02491d1cc9eec2f799e84eaa31bb"
        let userid = "24858431@N07"
        let api_sig = "5ccbab2ab1d5be85e118f588d31551be"

        let url : NSURL = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=\(apiKey)&user_id=\(userid)&extras=url_m&format=json&nojsoncallback=1&api_sig=\(api_sig)")!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            if (error != nil){
                
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Retry", style: .Default, handler: { (alert:UIAlertAction) -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    self.processJSON()
                    alertController.dismissViewControllerAnimated(true, completion: {})
                })
                
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: {})
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                return
            }
            
            do {
                let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                if let photos = jsonArray["photos"] as? NSDictionary{
                    if let photo = photos["photo"] as? NSArray{
                        for ph in photo {
                            if let imgUrl = ph["url_m"] as? String {
                                self.items.append(imgUrl)
                            }
                        }
                    }
                } else {
                    if let stat = jsonArray["stat"] as? String {
                        if let code = jsonArray["code"] as? Int {
                            if let message = jsonArray["message"] as? String{
                                let alertController = UIAlertController(title: stat, message: "code:\(code) - \(message)", preferredStyle: .Alert)
                                let okAction = UIAlertAction(title: "ok", style: .Default, handler: { (alert:UIAlertAction) -> Void in
                                    alertController.dismissViewControllerAnimated(true, completion: {})
                                })
                                
                                alertController.addAction(okAction)
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.presentViewController(alertController, animated: true, completion: {})
                                })
                                
                            }
                        }
                    }
                }
            } catch {
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView!.reloadData()
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            
        })
        
        task.resume()
        
    }}
