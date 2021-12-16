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
        
        var transition: UIViewControllerAnimatedTransitioning? = nil
        
        switch (fromVC, toVC) {
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

