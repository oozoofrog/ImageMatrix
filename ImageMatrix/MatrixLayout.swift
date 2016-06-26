//
//  MatrixLayout.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 6. 26..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit
import Accelerate

class MatrixLayout: UICollectionViewLayout {
    
    var cache = [UICollectionViewLayoutAttributes]()
 
    var col: Int = 0
    var size: Double = 0
    
    override func prepare() {
        if cache.isEmpty {
            
            var xOffsets = [Double].init(repeating: 0, count: col)
            var y = 0.0
            var start : Double = 0
            var increment : Double = Double(size)
            vDSP_vrampD(&start, &increment, &xOffsets, 1, vDSP_Length(xOffsets.count))
            let items = collectionView?.numberOfItems(inSection: 0) ?? 0
            let row = items / col + (0 < items % col ? 1 : 0)
            var index = 0
            for _ in 0..<row {
                for col in 0..<col {
                    let frame = CGRect(x: xOffsets[col], y: y, width: size, height: size)
                    let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
                    attribute.frame = frame
                    cache.append(attribute)
                    index += 1
                }
                y += size
            }
            
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for item in self.cache {
            if item.frame.intersects(rect) {
                attributes.append(item)
            }
        }
        return attributes
    }
    
    override func collectionViewContentSize() -> CGSize {
        let items = collectionView?.numberOfItems(inSection: 0) ?? 0
        let row = items / col + (0 < items % col ? 1 : 0)
        let width = Double(col) * size
        let height = Double(row) * size
        return CGSize(width: width, height: height)
    }
}
