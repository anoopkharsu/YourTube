//
//  PlayListTableViewCell.swift
//  YourTube
//
//  Created by Anoop Kharsu on 27/11/21.
//

import UIKit

class PlayListTableViewCell: UITableViewCell {
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var videoTitleLabelView: UILabel!
    @IBOutlet weak var viewCountLabelView: UILabel!
    @IBOutlet weak var publishTimeLabelView: UILabel!
    @IBOutlet weak var durationTimeLabelView: EdgeInsetLabel! {
        didSet {
            durationTimeLabelView.textInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
