//
//  BottomTransition.swift
//  iShare
//
//  Created by Anoop Kharsu on 06/09/21.
//

import UIKit

class NavigationControllerDelegate:  NSObject, UINavigationControllerDelegate {
    
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
//        VideoDetailViewController,
//           let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? CommentViewController
        var transition: UIViewControllerAnimatedTransitioning? = nil
        
        switch (fromVC, toVC) {
//        case (is VideoDetailViewController, is CommentViewController):
//
//            transition = BottomToTopTransition()
//        case (is CommentViewController, is VideoDetailViewController):
//            transition = TopToBottomTransition()
            
        case (is ChannelViewController, is VideoDetailViewController):
            transition = MoveElementsTransition()
            
        case (is VideoDetailViewController, is ChannelViewController):
            let moveElementsTransition = MoveElementsTransition()
            moveElementsTransition.operation = .pop
            transition = moveElementsTransition
            
        case (is HomeViewController, is VideoDetailViewController):
            transition = MoveElementsTransition()
            
        case (is VideoDetailViewController, is HomeViewController):
            let moveElementsTransition = MoveElementsTransition()
            moveElementsTransition.operation = .pop
            transition = moveElementsTransition
            
        case (is SearchViewController, is SearchResultViewController):
            let moveElementsTransition = MoveElementsTransition()
            moveElementsTransition.duration = 0.3
            moveElementsTransition.fromLeft = true
            transition = moveElementsTransition
            
        case (is SearchResultViewController, is SearchViewController):
            let moveElementsTransition = MoveElementsTransition()
            moveElementsTransition.fromLeft = true
            moveElementsTransition.duration = 0.3
            moveElementsTransition.operation = .pop
            transition = moveElementsTransition
            
        case (is SearchResultViewController, is VideoDetailViewController):
            let moveElementsTransition = MoveElementsTransition()
            transition = moveElementsTransition
        case (is VideoDetailViewController, is SearchResultViewController):
            let moveElementsTransition = MoveElementsTransition()
            moveElementsTransition.operation = .pop
            transition = moveElementsTransition
            
        case (is HomeViewController, is SearchViewController):
            transition = FromSearchToFullscreen()
            
        case (is SearchViewController, is HomeViewController):
            let searchTransition = FromSearchToFullscreen()
            searchTransition.operation = .pop
            transition = searchTransition
            
        default:
            transition = nil
        }
        
        return transition
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}


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
            if let tempToFrame = toViewController.frameForView?(toView) {
                toFrame = tempToFrame
            } else {
                toFrame = toView.superview!.convert(toView.frame, to: nil)
            }
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
    @objc optional func frameForView(_ subView: UIView) -> CGRect
}


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

class BottomToTopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval = 0.8
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? VideoDetailViewController,
           let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? CommentViewController{
            containerView.addSubview(fromViewController.view)
            containerView.addSubview(toViewController.view)
            toViewController.view.setNeedsLayout()
            toViewController.view.layoutIfNeeded()
            let safeare = toViewController.view.safeAreaInsets.top
            toViewController.view.frame = fromViewController.view.frame.offsetBy(dx: 0, dy: (fromViewController.view.frame.height - fromViewController.commentContainerView.frame.height) - safeare)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseOut], animations: { () -> Void in
                toViewController.view.frame = fromViewController.view.frame
            }) { (_) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class TopToBottomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval = 0.6
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from) as! CommentViewController
        let toViewController = transitionContext.viewController(forKey: .to) as! VideoDetailViewController
        guard let toView = transitionContext.view(forKey: .to) else {
                  transitionContext.completeTransition(false)
                  return
              }
        let containerView = transitionContext.containerView
        containerView.insertSubview(toView, at: 0)
        let bounds = containerView.bounds
        toView.frame = bounds
        let safeare = toViewController.view.safeAreaInsets.top
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseIn], animations: {
            fromViewController.view.frame = fromViewController.view.frame.offsetBy(dx: 0, dy: (toViewController.view.frame.size.height - toViewController.commentContainerView.frame.height) - safeare)
        }) { (_) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
}
