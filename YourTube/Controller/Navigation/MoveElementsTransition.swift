//
//  MoveElementsTransition.swift
//  YourTube
//
//  Created by Anoop Kharsu on 16/12/21.
//

import UIKit

class MoveElementsTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var operation: UINavigationController.Operation = .push
    var fromLeft = false
    var duration: TimeInterval = 0.6
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from) as! TransitionInfoProtocol
        let toViewController = transitionContext.viewController(forKey: .to) as! TransitionInfoProtocol
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        if operation == .pop {
            containerView.bringSubviewToFront(fromViewController.view)
        }
        
        toViewController.view.setNeedsLayout()
        toViewController.view.layoutIfNeeded()
        
        let fromViews = fromViewController.viewsToAnimate()
        let toViews = toViewController.viewsToAnimate()
        
        if fromViews.count != toViews.count {
            print(fromViews.count, toViews.count)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        assert(fromViews.count == toViews.count, "Number of elements in fromViews and toViews have to be the same.")
        
        var intermediateViews = [UIView]()
        
        var toFrames = [CGRect]()
        
        for i in 0..<fromViews.count {
            let fromView = fromViews[i]
            let fromFrame = fromView.superview!.convert(fromView.frame, to: nil)
            fromView.alpha = 0
            let intermediateView = fromViewController.copyForView(fromView, index: i)
            intermediateView.frame = fromFrame
            containerView.addSubview(intermediateView)
            intermediateViews.append(intermediateView)
            
            let toView = toViews[i]
            
            var toFrame: CGRect

            toFrame = toView.superview!.convert(toView.frame, to: nil)

            toFrames.append(toFrame)
            toView.alpha = 0
        }
        
        if operation == .push {
            if fromLeft {
                toViewController.view.frame = fromViewController.view.frame.offsetBy(dx: fromViewController.view.frame.size.width, dy: 0)
            } else {
                toViewController.view.layer.opacity = 0.5
                
            }
        }
        
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
            if self.operation == .pop {
                if self.fromLeft {
                    fromViewController.view.frame = fromViewController.view.frame.offsetBy(dx: fromViewController.view.frame.size.width, dy: 0)
                } else {
                    fromViewController.view.layer.opacity = 0
                }
                if toViewController is SearchResultViewController {
                    toViewController.popAnimation?()
                }
                
            } else {
                if self.fromLeft {
                    toViewController.view.frame = fromViewController.view.frame
                } else {
                    toViewController.view.layer.opacity = 1
                }
            }
            
            fromViewController.animationHeper?()
            for i in 0..<intermediateViews.count {
                let intermediateView = intermediateViews[i]
                intermediateView.frame = toFrames[i]
                intermediateView.backgroundColor = .clear
            }
        }) { (_) -> Void in
            for i in 0..<intermediateViews.count {
                intermediateViews[i].removeFromSuperview()
                
                fromViews[i].alpha = 1
                toViews[i].alpha = 1
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

@objc protocol TransitionInfoProtocol {
    var view: UIView! { get set }
    func viewsToAnimate() -> [UIView]
    func copyForView(_ subView: UIView, index: Int) -> UIView
    @objc optional func pushAnimation()
    @objc optional func popAnimation()
    @objc optional func animationHeper()
}
