//
//  PhotoCell.swift
//  PhotoCollection
//
//  Created by Gazolla on 23/01/16.
//  Copyright © 2016 Gazolla. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var photo:Photo? {
        didSet{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.activityIndicator.startAnimating()
            })
        }
    }
    
    lazy var activityIndicator:UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        return ai
    }()
    
    lazy var imageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = UIViewContentMode.ScaleAspectFit
        iv.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.activityIndicator)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
        self.activityIndicator.center = CGPointMake(self.bounds.width/2, self.bounds.height/2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    func loadImage(completion:(image:UIImage)->()){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.photo!.imgUrl!)!)!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityIndicator.stopAnimating()
                    completion(image: image!)
                    self.setNeedsDisplay()
            })
        }

    }
}
