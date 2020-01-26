//
//  PhotoCVC.swift
//  ArtemiyLiveWallpapers
//
//  Created by Artem Kuprijanets on 1/26/20.
//  Copyright © 2020 Artem Kuprijanets. All rights reserved.
//

import UIKit

class PhotoCVC: UICollectionViewCell {
    
  @IBOutlet weak var imageView: UIImageView!
  
  func setCell(image: UIImage) {
    
    imageView.image = image
  }
}
