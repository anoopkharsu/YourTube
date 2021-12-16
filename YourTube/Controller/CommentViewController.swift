//
//  CommentViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 03/12/21.
//

import UIKit

class CommentViewController: UIViewController {

    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTableView: UITableView!
    var comments: Comments? = nil
    var videoData: VideoWithData? = nil
    var once = false
    var nextToken: String? = nil
    var parentID = ""
    @IBOutlet weak var navItems: UINavigationItem!
    
    @IBAction func cancelPressed1(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        commentTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        let label = UILabel()
        let commentAttribute = [ NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)  ]
        let commentCountAttribute = [ NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)  ]
        let string = NSMutableAttributedString(string: "Comments  ", attributes: commentAttribute)
        string.append(NSMutableAttributedString(string: videoData?.commentsCount ?? "", attributes: commentCountAttribute))
        label.attributedText = string
        navItems.titleView = label
    }
    
    var fetchComments = false
    func getNext(){
        if fetchComments {
            return
        }
        fetchComments = true
        DispatchQueue.global().async {
            self.comments?.fetchCommentResource(pageToken: self.nextToken) { comments in
                DispatchQueue.main.async {
                    self.nextToken = comments.nextPageToken
                    comments.items?.forEach({ comment in
                        self.comments?.comments.append(Comment(commentThread: comment, comment: comment.snippet?.topLevelComment))
                    })
                    self.commentTableView.reloadData()
                    self.fetchComments = false
                }
            }
        }
    }
    var images = [String: Data]()
    func getImage(index: IndexPath) -> Data? {
        if let data = images[comments!.comments[index.item].url] {
            return data
        } else {
            DispatchQueue.global().async {
                if let data = self.comments!.comments[index.item].authorProfilePicData() {
                    self.images[self.comments!.comments[index.item].url] = data
                    DispatchQueue.main.async {
                        self.commentTableView.reloadRows(at: [index], with: .none)
                    }
                }
            }
        }
        return nil
    }
    var topComment: Comment? = nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? CommentRepliesViewController {
            des.parentId = parentID
            des.topComment = topComment
        }
    }
}


extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments?.comments.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        if let cell = cell as? CommentTableViewCell ,let comment = comments?.comments[indexPath.item]{
            
            cell.replyClicked = {
                self.parentID = comment.id
                self.topComment = comment
                self.performSegue(withIdentifier: "replysegue", sender: self)
            }
            cell.authorNameLabelView.text = comment.authorName
            cell.commentTextLabelView.text = comment.commentText
            
            cell.likesLabelView.text = comment.likesCount
            cell.repliesCountLabelView.text = comment.repliesCount
            cell.publishTimeLabelView.text = comment.publishTime
            if comment.repliesCount == "0" {
                cell.replyButtonView.isHidden = true
            } else {
                cell.replyButtonView.isHidden = false
                cell.replyButtonView.setTitle("\(comment.repliesCount) REPLIES", for: .normal)
            }
            
            if let data = getImage(index: indexPath) {
                cell.authorPicImaheView.image = UIImage(data: data)
            } else {
                cell.authorPicImaheView.image = nil
            }
            
            if indexPath.item == (comments!.comments.count - 1) && indexPath.item < ((videoData?.commentCountInt ?? 0) - 1) {
                getNext()
            }
        }
        return cell
    }
    
}
 
