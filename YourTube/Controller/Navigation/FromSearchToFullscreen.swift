//
//  FromSearchToFullscreen.swift
//  YourTube
//
//  Created by Anoop Kharsu on 16/12/21.
//

import UIKit


class FromSearchToFullscreen: NSObject, UIViewControllerAnimatedTransitioning {
    var operation: UINavigationController.Operation = .push
    
    private let duration: TimeInterval = 0.3
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        
        if operation == .push {
            let fromViewController = transitionContext.viewController(forKey: .from) as! HomeViewController
            let toViewController = transitionContext.viewController(forKey: .to) as! SearchViewController
            containerView.addSubview(fromViewController.view)
            containerView.addSubview(toViewController.view)
            toViewController.view.setNeedsLayout()
            toViewController.view.layoutIfNeeded()
            
            let frame = toViewController.view.frame
            if let view = fromViewController.searchBarButtom?.value(forKey: "view") as? UIView {
                
                toViewController.view.frame = view.frame.offsetBy(dx: frame.width, dy: 0)
                toViewController.lastFrame = view.frame.offsetBy(dx: frame.width, dy: 0)
                
                toViewController.view.layer.cornerRadius = frame.width / 2
            }
            toViewController.view.layer.opacity = 0
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseInOut], animations: {
                toViewController.navigationController?.navigationBar.isHidden = true
                toViewController.view.frame = frame
                toViewController.view.layer.cornerRadius = 0
                toViewController.view.layer.opacity = 1
            }) { (_) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                toViewController.view.layer.cornerRadius = 0
                
            }
        } else {
            let fromViewController = transitionContext.viewController(forKey: .from) as! SearchViewController
            let toViewController = transitionContext.viewController(forKey: .to) as! HomeViewController
            guard let fromView = transitionContext.view(forKey: .from),
                  let toView = transitionContext.view(forKey: .to) else {
                      transitionContext.completeTransition(false)
                      return
                  }
            
            let containerView = transitionContext.containerView
            containerView.insertSubview(toView, at: 0)
            let bounds = containerView.bounds
            toView.frame = bounds
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseIn], animations: {
                fromView.layer.cornerRadius = fromView.frame.width / 2
                fromView.frame = fromViewController.lastFrame
                fromView.layer.opacity = 0
                toViewController.navigationController?.navigationBar.isHidden = false
            }) { (_) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

