//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Stu Almeleh on 4/12/16.
//  Copyright © 2016 Stu Almeleh. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if imageView.image == nil {
            activityIndicator.startAnimating()
            
            imageView.image = UIImage(named: "Stack of Photos Filled-100.png")
        }
        else {
            activityIndicator.stopAnimating()
        }
    }
    
}
