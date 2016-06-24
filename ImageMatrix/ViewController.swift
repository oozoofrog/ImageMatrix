//
//  ViewController.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 6. 24..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit
import PhotosUI

extension UIImageView {
    func image(forName name: String) {
        self.image = UIImage(named: name)
    }
}

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageView.contentMode = .scaleAspectFit
        imageView.image(forName: "texture")
        
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 10.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBAction func convolve(_ sender: AnyObject) {
        let sheet = UIAlertController(title: "Convolve", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Edge 3x3", style: .default, handler: { (action) in
            self.imageView.image = self.imageView.image?.applyConvolve(kernel: [-2, 0, 0, 0, 1, 0, 0, 0, 2], row: 3, col: 3)
            self.imageView.setNeedsDisplay()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(sheet, animated: true, completion: nil)
    }
    
}

