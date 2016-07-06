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
            loadImage(photo!.imgUrl!)
        }
    }
    
    lazy var imageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = UIViewContentMode.ScaleAspectFit
        iv.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    func loadImage(named:String){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: named)!)!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageView.image = image
            })
        }

    }
}
