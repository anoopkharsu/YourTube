//
//  VideoDetailViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 12/11/21.
//

import UIKit
import SwiftUI
import GoogleAPIClientForREST
import WebKit
class VideoDetailViewController: UIViewController {
    
    @IBOutlet weak var durationLabelView: EdgeInsetLabel!{
        didSet {
            durationLabelView.textInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        }
    }
    @IBOutlet weak var commentNavBar: UINavigationBar!
    @IBOutlet weak var videoPresenterWebView: WKWebView!
    @IBOutlet weak var videoThumbnailImage: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var channelImageVIew: UIImageView!
    @IBOutlet weak var likeDislikeShareStackView: UIStackView!
    @IBOutlet weak var channelNameLabelView: UILabel!
    @IBOutlet weak var viewCountLabelView: UILabel!
    @IBOutlet weak var publishedTimeLabelView: UILabel!
    @IBOutlet weak var likeCountLabelView: UILabel!
    @IBOutlet weak var dislikeCountLabelView: UILabel!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var videoDetailButton: UIButton!

    @IBOutlet weak var subscriberCountLabelView: UILabel!
    @IBOutlet weak var commentContainerView: UIView! {
        didSet {
            let panGesture = UIPanGestureRecognizer(target: self, action:#selector(self.handlePanGesture))
            let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.handleTapGesture))
            commentContainerView.addGestureRecognizer(tapGesture)
            commentContainerView.addGestureRecognizer(panGesture)
        }
    }
    @IBOutlet weak var channelContainerStackView: UIStackView! {
        didSet {
            let g = UITapGestureRecognizer(target: self, action: #selector(tappedForChannel))
            channelContainerStackView.addGestureRecognizer(g)
        }
    }
    @objc func tappedForChannel(){
        if prive == "channel" {
            navigationController?.popViewController(animated: true)
            return
        }
        if let channelController = storyboard?.instantiateViewController(identifier: "ChannelViewController") as? ChannelViewController {
            navigationItem.backButtonTitle = videoData?.channelName ?? "Back"
//            if let id = video.channelId {
//                channelController.channelId = id
//                channelController.channel = video
//                navigationController?.pushViewController(channelController, animated: true)
//            }
            
            if let id = videoData?.channelId {
                channelController.channelId = id
                channelController.channel = videoData
                navigationController?.pushViewController(channelController, animated: true)
            }
        }
    }
    @IBOutlet weak var commentTable: UITableView!
    var comments = Comments(videosID: "")
    var pageToken: String? = nil
    @objc func handleTapGesture(panGesture: UITapGestureRecognizer) {
        performSegue(withIdentifier: "CommentsSegue", sender: self)
    }
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        
        switch panGesture.state {
        case .began:
            performSegue(withIdentifier: "CommentsSegue", sender: self)
            
        default:
            break
        }
        
    }
    var appeared = false
    var videoData: VideoWithData? = nil
    var startX = CGFloat(0)
    var navigationControllerDelegate: NavigationControllerDelegate?
    var prive = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        durationLabelView.text = videoData?.durationString ?? ""
        
        commentTable.dataSource = self
        commentTable.delegate = self
        hideViews()
        
        if let thumbnailData = videoData?.thumbnailData, let channelImageData = videoData?.channelImageData {
            videoThumbnailImage.image = UIImage(data: thumbnailData)
            channelImageVIew.image = UIImage(data: channelImageData)
        }
        if let videosID = videoData?.id {
            comments.videosID = videosID
            if let url = URL(string: "https://www.youtube.com/embed/\(videosID)") {
                let request = URLRequest(url: url)
                videoPresenterWebView.load(request)
            }
        } else {
            
        }
        let label = UILabel()
        let commentAttribute = [ NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)  ]
        let commentCountAttribute = [ NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)  ]
        let string = NSMutableAttributedString(string: "Comments  ", attributes: commentAttribute)
        string.append(NSMutableAttributedString(string: videoData?.commentsCount ?? "", attributes: commentCountAttribute))
        label.attributedText = string
        commentNavBar.topItem?.titleView = label
//        commentNavBar.topItem?.title = "Comment \(videoData?.commentsCount ?? "")"
        videoTitleLabel.text = videoData?.title ?? ""
        channelNameLabelView.text = videoData?.channelName ?? ""
        videoTitleLabel.sizeToFit()
        viewCountLabelView.text = videoData?.viewCounts ?? ""
        publishedTimeLabelView.text = videoData?.publishedTime ?? ""
        likeCountLabelView.text = videoData?.likesCount ?? ""
        dislikeCountLabelView.text = videoData?.dislikesCount ?? ""
        subscriberCountLabelView.text = videoData?.subscriberCount ?? ""
        
        commentTable.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        DispatchQueue.global().async {
            self.comments.fetchCommentResource(pageToken: self.pageToken) { comments in
                DispatchQueue.main.async {
                    self.pageToken = comments.nextPageToken
                    comments.items?.forEach({ comment in
                        self.comments.comments.append(Comment(commentThread: comment, comment: comment.snippet?.topLevelComment))
                    })
                    print(self.comments.comments.count)
                    self.commentTable.reloadData()
                }
            }
        }
        //        tableView.register(UINib(nibName: "PlayListTableViewCell", bundle: nil), forCellReuseIdentifier: "PlayListCell")
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func videoDetailButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "VideoDescriptionSegue", sender: self)
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        
        guard let id = videoData?.id else {
            return
        }
        let secondActivityItem : NSURL = NSURL(string: "https://www.youtube.com/watch?v=\(id)")!
        
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [ secondActivityItem], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = sender
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? VideoDescriptionViewController {
            des.item = videoData?.item
            des.channelImageData = videoData?.channelImageData
            des.heightOfTop = videoThumbnailImage.frame.height + (navigationController?.navigationBar.frame.height ?? 0)
            des.videosWithData = videoData
        } else if let commentController = segue.destination as? CommentContainerViewController  {
            
            commentController.comments = comments
            commentController.videoData = videoData
            commentController.top = videoThumbnailImage.frame.height + (navigationController?.navigationBar.frame.height ?? 0)
            commentController.nextToken = pageToken
            commentController.images = images
        }
    }
    
    @IBAction func pinPressed(_ sender: UIButton) {
       
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) { [self] in
                unhideViews()
                self.navigationController?.navigationBar.isHidden = false
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("appeared")
        if appeared {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) { [self] in
                unhideViews()
            }
        }
        appeared = true
        
    }
    
    @IBAction func leftSwipeGestureHandler(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let percent = min(1, max(0, (translation.x - startX)/200))
        
        switch sender.state {
        case .began:
            hideViews()
            startX = translation.x
            navigationControllerDelegate?.interactiveTransition = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewController(animated: true)
        case .changed:
            navigationControllerDelegate?.interactiveTransition?.update(percent)
        case .ended:
            fallthrough
        case .cancelled:
            if sender.velocity(in: sender.view).x < 1 && percent < 0.5 {
                navigationControllerDelegate?.interactiveTransition?.cancel()
            } else {
                navigationControllerDelegate?.interactiveTransition?.finish()
            }
            navigationControllerDelegate?.interactiveTransition = nil
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationControllerDelegate = navigationController?.delegate as? NavigationControllerDelegate
    }
    
    func unhideViews(){
        videoPresenterWebView.layer.opacity = 1
        videoDetailButton.layer.opacity = 1
  
        likeDislikeShareStackView.layer.opacity = 1
        channelNameLabelView.layer.opacity = 1
        subscriberCountLabelView.layer.opacity = 1
        commentContainerView.layer.opacity = 1
    }
    
    func hideViews() {
        videoPresenterWebView.layer.opacity = 0
        commentContainerView.layer.opacity = 0
        videoDetailButton.layer.opacity = 0
        
        subscriberCountLabelView.layer.opacity = 0
        likeDislikeShareStackView.layer.opacity = 0
        channelNameLabelView.layer.opacity = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    var images = [String: Data]()
    func getImage(index: IndexPath) -> Data? {
        if let data = images[comments.comments[index.item].url] {
            return data
        } else {
            DispatchQueue.global().async {
                if let data = self.comments.comments[index.item].authorProfilePicData() {
                    DispatchQueue.main.async {
                        self.images[self.comments.comments[index.item].url] = data
                        self.commentTable.reloadRows(at: [index], with: .none)
                    }
                }
            }
        }
        return nil
    }
    
}

extension VideoDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        if let cell = cell as? CommentTableViewCell {
            let comment = comments.comments[indexPath.item]
            cell.replyClicked = {
                print("clcicted")
            }
            cell.authorNameLabelView.text = comment.authorName
            cell.commentTextLabelView.text = comment.commentText
            
            cell.likesLabelView.text = comment.likesCount
            cell.repliesCountLabelView.text = comment.repliesCount
            cell.publishTimeLabelView.text = comment.publishTime
            
            if let data = getImage(index: indexPath) {
                cell.authorPicImaheView.image = UIImage(data: data)
            } else {
                cell.authorPicImaheView.image = nil
            }
            
            if comment.repliesCount == "0" {
                cell.replyButtonView.isHidden = true
            } else {
                cell.replyButtonView.isHidden = false
                cell.replyButtonView.setTitle("\(comment.repliesCount) REPLIES", for: .normal)
            }
            
        }
        return cell
    }
}

extension VideoDetailViewController: TransitionInfoProtocol {
    
    
    func viewsToAnimate() -> [UIView] {
        if prive == "channel" {
            return [ videoThumbnailImage, videoTitleLabel, viewCountLabelView, publishedTimeLabelView, durationLabelView]
        }
        return [ videoThumbnailImage, channelImageVIew, videoTitleLabel, viewCountLabelView, publishedTimeLabelView, durationLabelView]
    }
    
    func copyForView(_ subView: UIView, index: Int) -> UIView {
        if prive == "channel" {
            switch index {
            case 0:
                return UIImageView(image: videoThumbnailImage.image)
                
            case 1:
                let label = UILabel()
                label.numberOfLines = 0
                label.text = videoTitleLabel.text
                label.font = videoTitleLabel.font
                label.sizeToFit()
                return label
                
            case 2:
                let label = UILabel()
                label.numberOfLines = 0
                label.text = viewCountLabelView.text
                label.font = viewCountLabelView.font
                label.textColor = .secondaryLabel
                label.sizeToFit()
                return label
            case 3:
                let label = UILabel()
                label.numberOfLines = 0
                label.text = publishedTimeLabelView.text
                label.font = publishedTimeLabelView.font
                label.textColor = .secondaryLabel
                label.sizeToFit()
                return label
            case 4:
                let label = EdgeInsetLabel()
                label.numberOfLines = 0
                label.textInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
                label.text = durationLabelView.text
                label.font = durationLabelView.font
                label.textColor = UIColor(named: "TimeTextColor")
                label.backgroundColor = UIColor(named: "TimeLabelBackground")
                label.sizeToFit()
                return label
            default:
                return UIView()
            }
        }
        
        
        switch index {
        case 0:
            return UIImageView(image: videoThumbnailImage.image)
        case 1:
            
            let image = UIImageView(image: channelImageVIew.image)
            image.clipsToBounds = true
            image.layer.cornerRadius = 20
            return image
            
        case 2:
            let label = UILabel()
            label.numberOfLines = 0
            label.text = videoTitleLabel.text
            label.font = videoTitleLabel.font
            label.sizeToFit()
            return label
            //        case 3:
            //            let label = UILabel()
            //            label.numberOfLines = 0
            //            label.text = channelNameLabelView.text
            //            label.font = channelNameLabelView.font
            //            label.textColor = .secondaryLabel
            //            label.sizeToFit()
            //            return label
            //            return UIView()
        case 3:
            let label = UILabel()
            label.numberOfLines = 0
            label.text = viewCountLabelView.text
            label.font = viewCountLabelView.font
            label.textColor = .secondaryLabel
            label.sizeToFit()
            return label
        case 4:
            let label = UILabel()
            label.numberOfLines = 0
            label.text = publishedTimeLabelView.text
            label.font = publishedTimeLabelView.font
            label.textColor = .secondaryLabel
            label.sizeToFit()
            return label
        case 5:
            let label = EdgeInsetLabel()
            label.numberOfLines = 0
            label.textInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            label.text = durationLabelView.text
            label.font = durationLabelView.font
            label.textColor = UIColor(named: "TimeTextColor")
            label.backgroundColor = .black
            label.sizeToFit()
            return label
        default:
            return UIView()
        }
        
    }
    
    
}
