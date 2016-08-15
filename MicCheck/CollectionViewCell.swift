//
//  CollectionViewCell.swift
//  MicCheck
//
//  Created by Eric Nash on 4/6/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit


class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imgArtistView: UIImageView!
    @IBOutlet var labelArtist: UILabel!
    @IBOutlet var labelVenue: UILabel!

    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)

    }
    
}

