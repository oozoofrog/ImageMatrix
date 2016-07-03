//
//  NavigationAnimator.swift
//  ImageMatrix
//
//  Created by 메이 on 2016. 7. 3..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import UIKit

class NavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.25
    var fromView: UIView?
    var toView: UIView?
    var transition: UIViewControllerContextTransitioning?
    
    let operation: UINavigationControllerOperation
    init(navigationOperation operation: UINavigationControllerOperation) {
        self.operation = operation
    }
    
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    func animationEnded(_ transitionCompleted: Bool) {
        print(#function)
    }
    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transition = transitionContext
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey) else {
                return
        }
        guard let fromView = fromVC.view.snapshotView(afterScreenUpdates: true),
            let toView = toVC.view.snapshotView(afterScreenUpdates: true) else {
                return
        }
        let container = transitionContext.containerView()
        switch operation {
        case .push:
            container.addSubview(fromView)
            container.addSubview(toView)
            toView.alpha = 0.0
            toView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: duration, animations: {
                toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                toView.alpha = 1.0
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { (done) in
                toView.removeFromSuperview()
                fromView.removeFromSuperview()
                container.addSubview(toVC.view)
                transitionContext.completeTransition(false == transitionContext.transitionWasCancelled())
            }
        case .pop:
            container.addSubview(toView)
            container.addSubview(fromView)
            toView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: duration, animations: {
                toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                fromView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                fromView.alpha = 0.0
            }) { (done) in
                toView.removeFromSuperview()
                fromView.removeFromSuperview()
                container.addSubview(toVC.view)
                transitionContext.completeTransition(false == transitionContext.transitionWasCancelled())
            }
        default:
            break
        }
    }
}
