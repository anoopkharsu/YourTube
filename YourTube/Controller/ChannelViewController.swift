//
//  ChannelPageViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 11/12/21.
//

import UIKit
import Accelerate

class ChannelViewController: UIViewController {
    var channel: VideoWithData? = nil
    var channelId = ""
    @IBOutlet weak var videoLabelView: UILabel!
    @IBOutlet weak var sectionLabelView: UILabel!
    @IBOutlet weak var leftDistanceOfBar: NSLayoutConstraint!
    @IBOutlet weak var widthOfBar: NSLayoutConstraint!
    var xDistanceVector: [Float] = []
    var widthVector: [Float] = []
    var pageViewController: ChannelPageViewController? = nil
    @IBOutlet weak var barView: UIView!
    var once = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !once {
            widthOfBar.constant = sectionLabelView.frame.width
            leftDistanceOfBar.constant = sectionLabelView.frame.minX
            xDistanceVector = vDSP.ramp(in: Float(sectionLabelView.frame.minX) ... Float(videoLabelView.frame.minX),count: 1001)
            if sectionLabelView.frame.width > videoLabelView.frame.width {
                widthVector = vDSP.ramp(in: Float(videoLabelView.frame.width)...Float(sectionLabelView.frame.width),count: 1001)
            } else {
                widthVector = vDSP.ramp(in: Float(sectionLabelView.frame.width)...Float(videoLabelView.frame.width),count: 1001)
            }
        }
        once = true
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? ChannelPageViewController {
            pageViewController = des
            des.video = channel
            des.channelId = channelId
            des.mover = { index in
                switch index {
                case 0...1000:
                    self.leftDistanceOfBar.constant = CGFloat(self.xDistanceVector[index])
                    self.widthOfBar.constant = CGFloat(self.widthVector[index])
                default:
                    return
                }
            }
        }
    }
    

}


extension ChannelViewController: TransitionInfoProtocol {
    func animationHeper() {
        if let con = pageViewController {
            con.animationHeper()
        }
    }
    
    func viewsToAnimate() -> [UIView] {
        if let con = pageViewController {
            return con.viewsToAnimate()
        }
        return []
    }
    
    func copyForView(_ subView: UIView, index: Int) -> UIView {
        if let con = pageViewController {
            return con.copyForView(subView, index: index)
        }
        return UIView()
    }
    
    
}

