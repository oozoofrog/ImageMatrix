//
//  MatrixDataSource.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 6. 26..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit

enum ImageComponentTag: Hashable, CustomStringConvertible {
    case R, G, B, A
    
    var description: String {
        switch self {
        case .A:
            return "A"
        case .B:
            return "B"
        case .G:
            return "G"
        case .R:
            return "R"
        }
    }
}

protocol ImageComponentProtocol {
    var tag: ImageComponentTag { get }
    var pixel: UInt8 { get }
}

struct ImageComponent: ImageComponentProtocol, CustomStringConvertible {
    let tag: ImageComponentTag
    let pixel: UInt8
    
    var description: String {
        return "\(tag): \(pixel)"
    }
}

protocol ImagePixelProtocol {
    var pixels: [ImageComponentTag:ImageComponent] { get }
    var grayed: Bool { get }
    var color: UIColor { get }
}

extension ImagePixelProtocol {
    var grayed: Bool {
        if 1 == pixels.count {
            return true
        }
        let first = pixels[.R]?.pixel
        for pixel in pixels {
            if first != pixel.value.pixel {
                return false
            }
        }
        return true
    }
    
    var color: UIColor {
        return UIColor(red: CGFloat(pixels[.R]?.pixel ?? 0) / 255.0, green: CGFloat(pixels[.G]?.pixel ?? 0) / 255.0, blue: CGFloat(pixels[.B]?.pixel ?? 0) / 255.0, alpha: CGFloat(pixels[.A]?.pixel ?? 0) / 255.0)
    }
}

struct ImagePixel: ImagePixelProtocol{
    let pixels: [ImageComponentTag:ImageComponent]
    init(ptr: UnsafePointer<UInt8>, length: Int, alphaInfo: CGImageAlphaInfo) {
        var pixels = [ImageComponentTag:ImageComponent]()
        var start: Int = 0
        var end: Int = length
        switch alphaInfo {
        case .first:
            start = 1
            pixels[.A] = ImageComponent(tag: .A, pixel: ptr[0])
        case .last:
            start = 0
            pixels[.A] = ImageComponent(tag: .A, pixel: ptr[length-1])
            end -= 1
        default:
            start = 0
        }
        pixels[.R] = ImageComponent(tag: .R, pixel: ptr[start])
        if start + 1 < end {
            pixels[.G] = ImageComponent(tag: .G, pixel: ptr[start + 1])
        }
        else {
            pixels[.G] = pixels[.R]
        }
        if start + 2 < end {
            pixels[.B] = ImageComponent(tag: .B, pixel: ptr[start + 2])
        }
        else {
            pixels[.B] = pixels[.R]
        }
        self.pixels = pixels
    }
}

protocol ImageArrayProtocol {
    var tag: ImageComponentTag { get }
    var array: [UInt] { get }
}

struct ImageArray: ImageArrayProtocol {
    let tag: ImageComponentTag
    let array: [UInt]
}


protocol ImageDataSourceable {
    var numberofStreamLength: Int { get }
    var numberofComponents: Int { get }
    var lengthOfImageData: Int { get }
    var bytes: UnsafePointer<UInt8> { get }
    var row: Int { get }
    var col: Int { get }
    func pixel(row: Int, col: Int) -> ImagePixel
}


extension ImageDataSourceable where Self: CGImage {
    var numberofStreamLength: Int {
        return self.width * self.height
    }
    
    var numberofComponents: Int {
        return self.bitsPerPixel / self.bitsPerComponent
    }
    
    var lengthOfImageData: Int {
        let data = self.dataProvider!.data!
        return CFDataGetLength(data)
    }
    
    var bytes: UnsafePointer<UInt8> {
        let data = self.dataProvider!.data!
        return CFDataGetBytePtr(data)
    }
    
    var row: Int {
        return self.height
    }
    
    var col: Int {
        return self.width
    }
    
    func pixel(row: Int, col: Int) -> ImagePixel {
        let streamIndex = bytesPerRow * row + col * numberofComponents
        let indexedPtr = bytes.advanced(by: streamIndex)
    
        return ImagePixel(ptr: indexedPtr, length: numberofComponents, alphaInfo: alphaInfo)
    }
    func pixel(indexPath: IndexPath) -> ImagePixel {
        let col = indexPath.row % self.width
        let row = indexPath.row / self.width + (0 < indexPath.row % self.width ? 1 : 0)
        return pixel(row: row, col: col)
    }
}

extension CGImage : ImageDataSourceable {}

struct MatrixDataSource {
    var imageDataSource: ImageDataSourceable
}

typealias ImageMatrixCellForItemHandle = (collectionView: UICollectionView, indexPath: IndexPath, pixel: ImagePixel) -> UICollectionViewCell

class ImageMatrixDataSource: NSObject, UICollectionViewDataSource {
    let cgImage: CGImage
    let cellHandle: ImageMatrixCellForItemHandle
    
    var pixels = [IndexPath: ImagePixel]()
    init(cgImage: CGImage, cellHandle: ImageMatrixCellForItemHandle) {
        self.cgImage = cgImage
        self.cellHandle = cellHandle
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cgImage.numberofStreamLength
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var pixel = self.pixels[indexPath]
        if nil == pixel {
            pixel = cgImage.pixel(indexPath: indexPath)
            self.pixels[indexPath] = pixel
        }
        return cellHandle(collectionView: collectionView, indexPath: indexPath, pixel: pixel!)
    }
}

