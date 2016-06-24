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
    var bitsPerPixel: Int { get }
    var rawWidth: Int { get }
    var rawHeight: Int { get }
    
    var dataSize: UInt { get }
}

protocol ImageDSP {
    func applyConvolve(kernel:[Float], row: Int, col: Int) -> UIImage?
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
    
    var bitsPerPixel: Int {
        return componentsPerPixel * 8
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
        let imageRef = CGImage(width: rawWidth, height: rawHeight, bitsPerComponent: 8, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: cgImage!.bitmapInfo, provider: dataProvider!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)!
        return UIImage(cgImage: imageRef)
    }
    
}
