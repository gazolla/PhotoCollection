//
//  MainViewController.swift
//  PhotoCollection
//
//  Created by Gazolla on 23/01/16.
//  Copyright © 2016 Gazolla. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    lazy var collectionView:UICollectionView = {
        let cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.layout)
        cv.backgroundColor = UIColor.whiteColor()
        cv.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        cv.delegate = self
        cv.dataSource = self
        cv.registerClass(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        return cv

    }()
    
    var layout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(2.0,20.0,2.0,20.0)
        return layout
    }()
    
    var items:[Photo]=[] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var error:NSError? {
        didSet {
            self.loadDataErrorMessage(error!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Flickr Photos"
        self.view.addSubview(self.collectionView)
    }
   
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PhotoCell
        let photo = self.items[indexPath.row]
        cell.photo = photo
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.bounds.width
        let cellSide = (width / 2) - 40
        return CGSizeMake(cellSide, cellSide)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadDataErrorMessage(error:NSError){
        let alertController = UIAlertController(title: "Error - \(error.code)", message: error.localizedDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "ok", style: .Default, handler: { (alert:UIAlertAction) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: {})
        })
        
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: {})
    }
}
