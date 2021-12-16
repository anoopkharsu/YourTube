//
//  CommentContainerViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 05/12/21.
//

import UIKit

class CommentContainerViewController: UIViewController {
    var top: CGFloat = 0
    var comments: Comments? = nil
    var videoData: VideoWithData? = nil
    var nextToken: String? = nil
    var images = [String: Data]()
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        topViewHeight.constant = top
        loadViewIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor(named: "dimBackground")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            self.view.backgroundColor = .clear
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationController?.updateFocusIfNeeded()
        if let des = segue.destination as? UINavigationController {
            if let des = des.viewControllers.first as? CommentViewController {
                des.videoData = videoData
                des.comments = comments
                des.nextToken = nextToken
                des.images = images
                
            }
        }
    }
}
