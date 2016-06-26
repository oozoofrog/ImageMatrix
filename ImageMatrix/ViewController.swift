//
//  ViewController.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 6. 26..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

    var dataSource: ImageMatrixDataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.dataSource = ImageMatrixDataSource(cgImage: UIImage(named: "2")!.cgImage!, cellHandle: { (collectionView, indexPath, pixel) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatrixCell", for: indexPath) as! MatrixCell
            cell.pixel = pixel
            return cell
        })
        let layout = collectionViewLayout as! MatrixLayout
        layout.col = 10 // dataSource.cgImage.width
        layout.size = 100
        self.collectionView?.dataSource = dataSource
        self.collectionView?.delegate = self
        self.collectionView?.reloadData()
    }
    
}
