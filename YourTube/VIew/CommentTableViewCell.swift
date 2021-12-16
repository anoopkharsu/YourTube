//
//  CommentTableViewCell.swift
//  YourTube
//
//  Created by Anoop Kharsu on 05/12/21.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var authorPicImaheView: UIImageView!
    @IBOutlet weak var authorNameLabelView: UILabel!
    @IBOutlet weak var publishTimeLabelView: UILabel!
    @IBOutlet weak var commentTextLabelView: UILabel!
    @IBOutlet weak var repliesCountLabelView: UILabel!
//    @IBOutlet weak var dislikeLabelView: UILabel!
    @IBOutlet weak var replyTextImageView: UIImageView!
    @IBOutlet weak var likesLabelView: UILabel!
    var replyClicked: (() -> Void)? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func replyButtonPressed(_ sender: UIButton) {
        replyClicked?()
    }
    @IBOutlet weak var replyButtonView: UIButton!
    
}
