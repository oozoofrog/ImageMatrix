//
//  MatrixDataSource.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 6. 26..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit
import Accelerate

enum ImageComponentTag: Hashable, CustomStringConvertible, Equatable {
    case r, g, b, a
    
    var description: String {
        switch self {
        case .a:
            return "A"
        case .b:
            return "B"
        case .g:
            return "G"
        case .r:
            return "R"
        }
    }
}

protocol ImageComponentProtocol {
    var tag: ImageComponentTag { get }
    var pixel: UInt8 { get }
}

struct ImageComponent: ImageComponentProtocol, CustomStringConvertible, Hashable, Equatable {
    let tag: ImageComponentTag
    let pixel: UInt8
    
    var description: String {
        return "\(tag): \(pixel)"
    }
    
    var hashValue: Int {
        return tag.hashValue ^ pixel.hashValue
    }
}

func ==<Comp: ImageComponentProtocol>(lhs: Comp, rhs: Comp) -> Bool {
    return lhs.tag == rhs.tag && lhs.pixel == rhs.pixel
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
        let first = pixels[.r]?.pixel
        for pixel in pixels {
            if first != pixel.value.pixel {
                return false
            }
        }
        return true
    }
    
    var color: UIColor {
        return UIColor(red: CGFloat(pixels[.r]?.pixel ?? 0) / 255.0, green: CGFloat(pixels[.g]?.pixel ?? 0) / 255.0, blue: CGFloat(pixels[.b]?.pixel ?? 0) / 255.0, alpha: CGFloat(pixels[.a]?.pixel ?? 0) / 255.0)
    }
}

func ==<Pix: ImagePixelProtocol>(lhs:Pix, rhs: Pix) -> Bool {
    return lhs.pixels == rhs.pixels
}
struct ImagePixel: ImagePixelProtocol, Hashable, Equatable{
    let pixels: [ImageComponentTag:ImageComponent]
    init(ptr: UnsafePointer<UInt8>, length: Int, alphaInfo: CGImageAlphaInfo) {
        var pixels = [ImageComponentTag:ImageComponent]()
        var start: Int = 0
        var end: Int = length
        switch alphaInfo {
        case .first:
            start = 1
            pixels[.a] = ImageComponent(tag: .a, pixel: ptr[0])
        case .last:
            start = 0
            pixels[.a] = ImageComponent(tag: .a, pixel: ptr[length-1])
            end -= 1
        default:
            start = 0
        }
        pixels[.r] = ImageComponent(tag: .r, pixel: ptr[start])
        if start + 1 < end {
            pixels[.g] = ImageComponent(tag: .g, pixel: ptr[start + 1])
        }
        else {
            pixels[.g] = pixels[.r]
        }
        if start + 2 < end {
            pixels[.b] = ImageComponent(tag: .b, pixel: ptr[start + 2])
        }
        else {
            pixels[.b] = pixels[.r]
        }
        self.pixels = pixels
    }
    
    var hashValue: Int {
        return pixels.reduce(0, combine: { (hash, other) -> Int in
            return hash ^ other.key.hashValue ^ other.value.hashValue
        })
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
    
}

protocol ImageDataPixelable {
    func pixel(_ row: Int, col: Int) -> ImagePixel
}

extension ImageDataSourceable where Self: CGImage, Self: ImageDataPixelable {
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
    
    func pixel(_ row: Int, col: Int) -> ImagePixel {
        let streamIndex = bytesPerRow * row + col * numberofComponents
        let indexedPtr = bytes.advanced(by: streamIndex)
    
        return ImagePixel(ptr: indexedPtr, length: numberofComponents, alphaInfo: alphaInfo)
    }
    func pixel(_ indexPath: IndexPath) -> ImagePixel {
        let col = indexPath.row % self.width
        let row = indexPath.row / self.width + (0 < indexPath.row % self.width ? 1 : 0)
        return pixel(row, col: col)
    }
}

extension CGImage : ImageDataSourceable, ImageDataPixelable {}

protocol KernelProtocol {
    var matrix: [Float] { get }
    var col: Int { get }
    var row: Int { get }
    
    func apply(_ pixel: ImagePixel, source: CGImage, row: Int, col: Int) -> ImagePixel
}

extension KernelProtocol {
    var row: Int {
        return matrix.count / col
    }
}

struct Kernel: KernelProtocol {
    let matrix: [Float]
    let col: Int
    var cache: [ImagePixel: ImagePixel] = [:]
    func apply(_ pixel: ImagePixel, source: CGImage, row: Int, col: Int) -> ImagePixel {
        if let pixel = cache[pixel] {
            return pixel
        }
        let kernelRows = self.row
        let kernelCols = self.col
        
        let la_matrix = la_matrix_from_float_buffer(matrix, la_count_t(kernelRows), la_count_t(kernelCols), la_count_t(kernelCols), la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
        
        let rowHalf = kernelRows / 2
        let colHalf = kernelCols / 2
        
        return pixel
    }
}

struct MatrixDataSource : ImageDataPixelable {
    var imageDataSource: CGImage
    var kernel: Kernel
    
    func pixel(_ row: Int, col: Int) -> ImagePixel {
        return self.imageDataSource.pixel(row, col: col)
    }
    
    func pixel(_ indexPath: IndexPath) -> ImagePixel {
        let col = indexPath.row % self.imageDataSource.col
        let row = indexPath.row / self.imageDataSource.col + (0 < indexPath.row % self.imageDataSource.col ? 1 : 0)
        return pixel(row, col: col)
    }
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
            pixel = cgImage.pixel(indexPath)
            self.pixels[indexPath] = pixel
        }
        return cellHandle(collectionView: collectionView, indexPath: indexPath, pixel: pixel!)
    }
}

