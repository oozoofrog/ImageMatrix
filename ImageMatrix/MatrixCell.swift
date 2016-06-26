//
//  MatrixCell.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 6. 26..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit

class MatrixCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    var pixel: ImagePixel? {
        didSet {
            guard let pixel = self.pixel else {
                self.backgroundColor = UIColor.clear()
                self.label.text = nil
                return
            }
            self.backgroundColor = pixel.color
            self.label.text = "\(pixel.pixels[.R]!)\n\(pixel.pixels[.G]!)\n\(pixel.pixels[.B]!)\n\(pixel.pixels[.A]!)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func randomColor() -> CGFloat {
        return CGFloat(arc4random_uniform(255)) / 255.0
    }
}
