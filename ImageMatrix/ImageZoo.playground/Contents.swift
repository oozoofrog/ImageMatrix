//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "2.png")!.cgImage!

let model = image.colorSpace!.model
switch model {
case .RGB:
    print("RGB")
default:
    break
}