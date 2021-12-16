//
//  VideoTableViewCell.swift
//  YourTube
//
//  Created by Anoop Kharsu on 08/11/21.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var viewCounts: UILabel!
    @IBOutlet weak var publishedTime: UILabel!
    @IBOutlet weak var channelImage: UIImageView!
    @IBOutlet weak var durationTimeLabelView: EdgeInsetLabel! {
        didSet {
            durationTimeLabelView.textInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        }
    }

    var id = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    //    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}

