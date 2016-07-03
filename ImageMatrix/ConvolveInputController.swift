//
//  ConvolveInputController.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 7. 3..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit

class ConvolveInputController: UICollectionViewController {
    
    lazy var convolveController: ConvolveInputControllerLayout = {
        return ConvolveInputControllerLayout()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.collectionView?.collectionViewLayout = self.convolveController
        self.collectionView?.delegate = self.convolveController
        self.collectionView?.dataSource = self.convolveController
        
        self.collectionView?.reloadData()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.customNavigationController?.setupGesture(view: self.view, handle: { (navigationController, operation) in
            switch operation {
            case .pop:
                navigationController.popViewController(animated: true)
            default:
                break
            }
        })
    }
    
}

class ConvolveInputControllerLayout : UICollectionViewLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let cols: Int = 3
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConvoleInputCell.Identifier, for: indexPath) as! ConvoleInputCell
        
        cell.inputField.text = String(indexPath.row)
        
        return cell
    }
    
    var cache: [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        let width = self.collectionView?.bounds.width ?? 0
        let height = self.collectionView?.bounds.height ?? 0
        let size = min(width, height)
        let startX = (self.collectionView?.bounds.midX ?? 0) - size / 2.0
        let startY = (self.collectionView?.bounds.midY ?? 0) - size / 2.0
        
        let count = (collectionView?.numberOfItems(inSection: 0) ?? 0)
        let rows = count / cols + (0 < count % cols ? 1 : 0)
        let itemWidth = size / CGFloat(cols)
        let itemHeight = size / CGFloat(rows)
        for index in 0..<count {
            let rowIndex = index / cols
            let colIndex = index % cols
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
            attributes.frame = CGRect(x: CGFloat(colIndex) * itemWidth + startX, y: CGFloat(rowIndex) * itemHeight + startY, width: itemWidth, height: itemHeight)
            cache.append(attributes)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        self.prepare()
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache
    }
}

class ConvoleInputCell : UICollectionViewCell {
    @IBOutlet weak var inputField: UITextField!
    
}
