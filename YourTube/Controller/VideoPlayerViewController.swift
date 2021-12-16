//
//  VideoPlayerViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 09/12/21.
//

import UIKit
import WebKit

class VideoPlayerViewController: UIViewController {
    @IBOutlet weak var videoPresenterWebView: WKWebView!
    var url: URL? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            let request = URLRequest(url: url)
            videoPresenterWebView.load(request)
        }
        // Do any additional setup after loading the view.
    }
    

}
