//
//  Protocols.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 7. 3..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit

protocol UIViewControllerStoryBoardIdentifierable {
    static var Identifier: String { get }
}

extension ViewController : UIViewControllerStoryBoardIdentifierable {
    static var Identifier: String {
        return "ViewController"
    }
}

extension ConvolveInputController : UIViewControllerStoryBoardIdentifierable {
    static var Identifier: String {
        return "ConvolveInput"
    }
}

extension ConvoleInputCell : UIViewControllerStoryBoardIdentifierable {
    static var Identifier : String {
        return "ConvoleInputCell"
    }
}
protocol CustomNavigationTransitioningDelegate : UINavigationControllerDelegate {
    var customNavigationController: CustomNavigationController? { get }
}

extension CustomNavigationTransitioningDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationAnimator(navigationOperation: operation)
    }
    
    var customNavigationController: CustomNavigationController? {
        switch self {
        case let vc as UIViewController:
            return vc.navigationController as? CustomNavigationController ?? nil
        default:
            return nil
        }
    }
}

extension ViewController : CustomNavigationTransitioningDelegate {}
extension ConvolveInputController : CustomNavigationTransitioningDelegate {}

typealias CustonNavigationGestureHandle = (navigationController: UINavigationController, operation: UINavigationControllerOperation) -> Void
class CustomNavigationController : UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var gesture: UIGestureRecognizer?
    var handle: CustonNavigationGestureHandle? = nil
//    var gestureView: UIView!
    var startScale: CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(CustomNavigationController.gestureEvent(_:)))
        pinch.cancelsTouchesInView = true
        pinch.delegate = self
        self.delegate = self
        self.gesture = pinch
    }
    func gestureEvent(_ gesture: UIGestureRecognizer) {
        switch gesture {
        case let pinch as UIPinchGestureRecognizer:
            self.pinch(pinch)
        default:
            break
        }
    }
    
    func pinch(_ pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            self.startScale = pinch.scale
        case .ended:
            if pinch.scale / self.startScale < 1.0 && -3 > pinch.velocity {
                self.handle?(navigationController: self, operation: .push)
            }
            else if pinch.scale / self.startScale > 1.0 && 3 < pinch.velocity{
                self.handle?(navigationController: self, operation: .pop)
            }
        default:
            break
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        self.gestureView.frame = self.view.bounds
    }
    
    func setupGesture(view childView: UIView, handle: CustonNavigationGestureHandle) {
        self.handle = handle
        childView.addGestureRecognizer(self.gesture!)
//        self.view.insertSubview(gestureView!, aboveSubview: childView)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
   
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationAnimator(navigationOperation: operation)
    }
}
