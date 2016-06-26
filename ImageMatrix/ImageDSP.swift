//
//  ImageDSP.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 6. 24..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit
import Accelerate


protocol ImageDSP {
    func applyConvolve(kernel:[Float], row: Int, col: Int) -> UIImage?
}

extension UIImage: ImageDSP {
  
}

extension UnsafeMutablePointer {
    func printMatrix(row: Int, col: Int) {
        for r in 0..<row {
            var rowString = ""
            for c in 0..<col {
                let format = String.init(format: "%0.3d", self[c + c*r] as? UInt8 ?? 0)
                rowString += "\(format), "
            }
            print("[\(rowString)]")
        }
    }
}

extension ImageDSP where Self: ImageDataSourceable, Self: UIImage{
    
    func applyConvolve(kernel:[Float], row: Int, col: Int) -> UIImage? {
       
        let srcData = CFDataCreateCopy(kCFAllocatorDefault, cgImage!.dataProvider!.data)!
        let srcBuffer = UnsafeMutablePointer<UInt8>(CFDataGetBytePtr(srcData))!
        
        let dstBufferSize = bytesPerRow * rawHeight
        let dstBuffer = UnsafeMutablePointer<UInt8>(malloc(dstBufferSize))!
        let bufferSize = rawWidth * rawHeight * sizeof(Float)
        let bufferLength = rawWidth * rawHeight
        let buffer = UnsafeMutablePointer<Float>(malloc(bufferSize))!
        
        defer {
            free(buffer)
        }
        print(componentsPerPixel)
        var min: Float = 0.0
        var max: Float = 255.0
        for i in 0..<componentsPerPixel {
            vDSP_vfltu8(srcBuffer.advanced(by: i), componentsPerPixel, buffer, 1, UInt(bufferLength))
            vDSP_imgfir(buffer, vDSP_Length(rawHeight), vDSP_Length(rawWidth), kernel, buffer, vDSP_Length(row), vDSP_Length(col))
            vDSP_vclip(buffer, 1, &min, &max, buffer, 1, vDSP_Length(bufferLength))
            vDSP_vfixu8(buffer, 1, dstBuffer.advanced(by: i), componentsPerPixel, vDSP_Length(bufferLength))
        }
        let dataProvider = CGDataProvider(dataInfo: nil, data: UnsafePointer<Void>(dstBuffer), size: dstBufferSize) { (info, data, size) in
            free(UnsafeMutablePointer<Void>(data))
        }
        print("rowHeight -> \(rawHeight)")
        srcBuffer.printMatrix(row: rawHeight, col: rawWidth * componentsPerPixel)
        print("\n")
        dstBuffer.printMatrix(row: rawHeight, col: rawWidth * componentsPerPixel)
        
        let imageRef = CGImage(width: rawWidth, height: rawHeight, bitsPerComponent: cgImage!.bitsPerComponent, bitsPerPixel: cgImage!.bitsPerPixel, bytesPerRow: cgImage!.bytesPerRow, space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo, provider: dataProvider!, decode: nil, shouldInterpolate: false, intent: cgImage!.renderingIntent)!
        return UIImage(cgImage: imageRef)
    }
    
}
