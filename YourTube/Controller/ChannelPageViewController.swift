//
//  ChannelPageViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 11/12/21.
//

import UIKit

extension ChannelPageViewController: TransitionInfoProtocol {
   
    func animationHeper() {
        if let con = pageViewControllers[currentIndex] as? TransitionInfoProtocol {
            con.animationHeper?()
        }
    }
    
    func viewsToAnimate() -> [UIView] {
        if let con = pageViewControllers[currentIndex] as? TransitionInfoProtocol {
            return con.viewsToAnimate()
        }
        return []
    }
    
    func copyForView(_ subView: UIView, index: Int) -> UIView {
        if let con = pageViewControllers[currentIndex] as? TransitionInfoProtocol {
            return con.copyForView(subView, index: index)
        }
        return UIView()
    }
    
    
}


class ChannelPageViewController: UIPageViewController, UIScrollViewDelegate {
    var channel: VideoWithData? = nil
    var channelId = ""
    var pageViewControllers = [UIViewController]()
    var mover: ((Int) -> Void)? = nil
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        if let c1 = storyboard?.instantiateViewController(identifier: "ChannelSectionViewController") as? ChannelSectionViewController,
              let c2 = storyboard?.instantiateViewController(identifier: "ChannelUploadsViewController") as? ChannelUploadsViewController  {
            c1.channelId = channelId
            c1.channel = channel
            c2.channel = channel
            pageViewControllers += [c1, c2]
            c1.view.tag = 0
            c2.view.tag = 1
            setViewControllers([c1], direction: .forward, animated: true)
        }
        let scrollView = view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self
        width = view.frame.width
    }
    
    var width:CGFloat = 0.0
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed)
          {
            return
          }
          currentIndex = pageViewController.viewControllers!.first!.view.tag
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let value = Int((scrollView.contentOffset.x / width) * 1000) - 1000
        if value < 0 && currentIndex == 1 {
            mover?(1000 + value)
        } else if value > 0 && currentIndex == 0{
            mover?(value)
        }
    }
}

extension ChannelPageViewController:  UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if pageViewControllers.firstIndex(of: viewController) == 1 {
            return pageViewControllers[0]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if pageViewControllers.firstIndex(of: viewController) == 0 {
            return pageViewControllers[1]
        }
        return nil
    }
    
    
  
}
