//
//  ImageMatrixTests.swift
//  ImageMatrixTests
//
//  Created by 메이 on 2016. 6. 24..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import XCTest
@testable import ImageMatrix

let row = 500
let col = 500

class ImageMatrixTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testO2Performance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let size = 100
            var cache = [UICollectionViewLayoutAttributes]()
            for r in 0..<row {
                for c in 0..<col {
                    let frame = CGRect(x: c * size, y: r * size, width: size, height: size)
                    let attribute = UICollectionViewLayoutAttributes()
                    attribute.frame = frame
                    cache.append(attribute)
                }
            }
        }
    
    }
    
    func testLinearPerformance() {
        
        self.measure {
            let size = 100
            let length = col * row
            var cache = [UICollectionViewLayoutAttributes]()
            
            for i in 0..<length {
                let x = CGFloat(i % col)
                let y = CGFloat(i / col)
                let frame = CGRect(x: x, y: y, width: CGFloat(size), height: CGFloat(size))
                let attribute = UICollectionViewLayoutAttributes()
                attribute.frame = frame
                cache.append(attribute)
            }
            
        }
    }
    
    func testGCDPerformance() {
        
        self.measure {
            let size = 100
            let length = col * row
            var cache = [UICollectionViewLayoutAttributes]()
            let sema = DispatchSemaphore(value: 0)
            
            let backgroundQueue = DispatchQueue(label: "background", attributes: [.serial])
            let looper = DispatchLooper(count: length, loopHandle: { (i) in
                let x = CGFloat(i % col)
                let y = CGFloat(i / col)
                let frame = CGRect(x: x, y: y, width: CGFloat(size), height: CGFloat(size))
                let attribute = UICollectionViewLayoutAttributes()
                attribute.frame = frame
                
                backgroundQueue.async(execute: {
                    cache.append(attribute)
                })
                }, loopCompletion: {
                    backgroundQueue.sync(execute: {
                        sema.signal()
                    })
            })
            looper.startLoop()
            sema.wait()
        }
    }
    
}

typealias DispatchLoopHandle = (index: Int) -> Void
typealias DispatchLoopCompletion = () -> Void

protocol DispatchLooperProtocol {
    var count: Int { get }
    var loopHandle: DispatchLoopHandle { get }
    var loopCompletion: DispatchLoopCompletion { get }
    
    func startLoop() -> Void
}

struct DispatchLooper : DispatchLooperProtocol {
    let count: Int
    let loopHandle: DispatchLoopHandle
    let loopCompletion: DispatchLoopCompletion
    let queue = DispatchQueue(label: "loop.queue", attributes: [.concurrent, .qosUtility])
    let group = DispatchGroup()
    func startLoop() {
        DispatchQueue.concurrentPerform(iterations: count) { (i) in
            group.enter()
            loopHandle(index: i)
            group.leave()
        }
        group.notify(queue: queue) { 
            self.loopCompletion()
        }
    }
}
