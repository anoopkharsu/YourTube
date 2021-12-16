//
//  VideoDescriptionViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 17/11/21.
//

import UIKit
import SwiftUI
import GoogleAPIClientForREST

class VideoDescriptionViewController: UIViewController {
    var item: GTLRYouTube_Video? = nil
    var channelImageData: Data?
    var videosWithData: VideoWithData? = nil
    var heightOfTop: CGFloat = 0
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var actualContainer: UIView!
    @IBOutlet weak var containerStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topConstraint.constant = heightOfTop
        loadViewIfNeeded()
        if let item = item, let data = channelImageData {
            let childView = UIHostingController(rootView: VideoDescriptionView(
                item: item,
                channelImageData: data,
                date: videosWithData?.item.snippet?.publishedAt ?? GTLRDateTime(),
                likes: videosWithData?.likesCount ?? "",
                viewCounts: Int(truncating: videosWithData?.item.statistics?.viewCount ?? 0)
            ){
                self.dismiss(animated: true, completion: nil)
            })
            addChild(childView)
            containerStack.addArrangedSubview(childView.view)
            childView.didMove(toParent: self)
        }
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

}
