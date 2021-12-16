//
//  ChannelTableViewCell.swift
//  YourTube
//
//  Created by Anoop Kharsu on 21/11/21.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var subscribersCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    @IBOutlet weak var channelBannerImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
