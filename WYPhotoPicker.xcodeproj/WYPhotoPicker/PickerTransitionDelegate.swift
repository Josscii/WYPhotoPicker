//
//  PickerTransitionDelegate.swift
//  WYPhotoPicker
//
//  Created by Josscii on 16/5/28.
//  Copyright © 2016年 Josscii. All rights reserved.
//

import UIKit

let screenHeight = UIScreen.mainScreen().bounds.height

class PickerTransitionDelegate: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var dimmingView: UIView!
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let fromView = fromVC.view
        let toView = toVC.view
        
        let duration = transitionDuration(transitionContext)
        
        if toVC.isBeingPresented() {
            
            dimmingView = UIView(frame: containerView.bounds)
            dimmingView.backgroundColor = UIColor.blackColor()
            dimmingView.alpha = 0
            
            containerView.addSubview(dimmingView)
            containerView.addSubview(toView)
            toView.frame.origin.y = screenHeight
            
            UIView.animateWithDuration(duration, animations: { 
                toView.frame.origin.y = 0
                self.dimmingView.alpha = 0.5
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
            
        } else if fromVC.isBeingDismissed() {
            UIView.animateWithDuration(duration, animations: {
                fromView.frame.origin.y = screenHeight
                self.dimmingView.alpha = 0
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
