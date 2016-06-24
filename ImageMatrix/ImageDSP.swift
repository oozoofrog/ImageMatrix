//
//  ImageDSP.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 6. 24..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit
import Accelerate

protocol ImageInfo {
    
    var bytesPerRow: Int { get }
    var componentsPerPixel: Int { get }
    var alphaInfo: CGImageAlphaInfo { get }
    var bitmapInfo: CGBitmapInfo { get }
    var rawWidth: Int { get }
    var rawHeight: Int { get }
    
    var dataSize: UInt { get }
}

protocol ImageDSP {
    func applyConvolve(kernel:[Int16], row: Int, col: Int) -> UIImage?
}

extension UIImage: ImageInfo, ImageDSP {
  
}

extension ImageInfo where Self: UIImage {
    var bytesPerRow: Int {
        guard let ref = cgImage else {
            return 0
        }
        return ref.bytesPerRow
    }
    
    var componentsPerPixel: Int {
        return bytesPerRow / rawWidth
    }
    
    var alphaInfo: CGImageAlphaInfo {
        guard let ref = cgImage else {
            return CGImageAlphaInfo.none
        }
        return ref.alphaInfo
    }
    
    var bitmapInfo: CGBitmapInfo {
        guard let ref = cgImage else {
            return CGBitmapInfo.init(rawValue: 0)
        }
        return ref.bitmapInfo
    }
    
    var rawWidth: Int {
        return cgImage?.width ?? 0
    }
    
    var rawHeight: Int {
        return cgImage?.height ?? 0
    }
    
    var dataSize: UInt {
        return UInt(bytesPerRow * rawHeight)
    }
}

extension ImageDSP where Self: ImageInfo, Self: UIImage{
    
    func applyConvolve(kernel:[Int16], row: Int, col: Int) -> UIImage? {
       
        var srcBuffer = malloc(Int(dataSize))
        var src = vImage_Buffer(data: srcBuffer, height: vImagePixelCount(rawHeight), width: vImagePixelCount(rawWidth), rowBytes: bytesPerRow)

        var dstBuffer = malloc(Int(dataSize))
        var dst = vImage_Buffer(data: dstBuffer, height: vImagePixelCount(rawHeight), width: vImagePixelCount(rawWidth), rowBytes: bytesPerRow)
        
        defer {
            free(srcBuffer)
            free(dstBuffer)
        }
        
        let space = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext.init(data: srcBuffer, width: rawWidth, height: rawHeight, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: space, bitmapInfo: self.alphaInfo.rawValue | self.bitmapInfo.rawValue)
        
        ctx?.draw(in: CGRect.init(x: 0, y: 0, width: rawWidth, height: rawHeight), image: cgImage!)
        
        vImageConvolve_ARGB8888(&src, &dst, nil, 0, 0, kernel, UInt32(row), UInt32(col), 1, nil, vImage_Flags(kvImageCopyInPlace))

        memcpy(UnsafeMutablePointer<Void>(srcBuffer), dstBuffer, Int(dataSize))
        
        print("finished")
        guard let ref = ctx?.makeImage() else {
            return nil
        }
        return UIImage(cgImage: ref)
    }
    
}
