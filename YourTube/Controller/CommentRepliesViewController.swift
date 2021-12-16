//
//  CommentRepliesViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 05/12/21.
//

import UIKit
import GoogleAPIClientForREST

class CommentRepliesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var parentId = ""
    var pageToken: String? = nil
    var replies = Replies()
    var topComment: Comment? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        replies.parentID = parentId
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        tableView.delegate = self
        tableView.dataSource = self
        if let topComment = topComment?.comment {
            replies.comment.append(Reply(comment: topComment))
        }
        
        getReplies()
    }
    var working = false
    func getReplies(){
        if working {
            return
        }
        working = true
        DispatchQueue.global().async {
            self.replies.fetchCommentResource(pageToken: self.pageToken) { response in
                self.pageToken = response.nextPageToken
                DispatchQueue.main.async {
                    response.items?.forEach({ comment in
                        self.replies.comment.append(Reply(comment: comment))
                    })
                    self.tableView.reloadData()
                    self.working = false
                }
            }
        }
        
    }
    var images = [String: Data]()
    
    func getImage(index: IndexPath) -> Data? {
        if let data = images[replies.comment[index.item].url] {
            return data
        } else {
            DispatchQueue.global().async {
                if let data = self.replies.comment[index.item].authorProfilePicData() {
                    self.images[self.replies.comment[index.item].url] = data
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [index], with: .none)
                    }
                }
            }
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

}


extension CommentRepliesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        replies.comment.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        if let cell = cell as? CommentTableViewCell {
            let comment = replies.comment[indexPath.item ]
           
            cell.authorNameLabelView.text = comment.authorName
            cell.commentTextLabelView.text = comment.commentText
            
            cell.likesLabelView.text = comment.likesCount
            cell.repliesCountLabelView.isHidden = true
            cell.publishTimeLabelView.text = comment.publishTime
            cell.replyTextImageView.isHidden = true
            cell.replyButtonView.isHidden = true
            if let data = getImage(index: indexPath) {
                cell.authorPicImaheView.image = UIImage(data: data)
            } else {
                cell.authorPicImaheView.image = nil
            }
            if indexPath.item == (replies.comment.count - 1) &&  indexPath.item < ((topComment?.repliesCountInt ?? 0) - 1){
                getReplies()
            }
            cell.mainView.backgroundColor = .systemBackground
            if indexPath.item == 0 {
                cell.replyTextImageView.isHidden = false
                cell.repliesCountLabelView.isHidden = false
                cell.mainView.backgroundColor = .secondarySystemBackground
                cell.repliesCountLabelView.text = topComment?.repliesCount ?? ""
            }
        }
        return cell
    }
    
}

struct Replies {
    var  comment: [Reply] = []
    var parentID = ""
   
    
    func fetchCommentResource(pageToken: String?, callBack: @escaping ( GTLRYouTube_CommentListResponse ) -> Void){
        let query = GTLRYouTubeQuery_CommentsList.query(withPart: ["snippet", "id"])
        query.pageToken = pageToken
        query.parentId = parentID
        query.textFormat = "plainText"
        Home.service.executeQuery(query) { response, _, error in
            if let error = error {
                print(error,"rrr")
                return
            }

            if let comments = response.fetchedObject as? GTLRYouTube_CommentListResponse {
                callBack(comments)
            }
        }
    }
}

struct Reply {
    let comment: GTLRYouTube_Comment
    
    var likesCount: String {
        if let likeCount = comment.snippet?.likeCount {
            return "\(viewCountConverter(views: Int(truncating: likeCount)))"
        }
        return ""
    }
    
    var url: String {
        if let url = comment.snippet?.authorProfileImageUrl {
            return url
        }
        return ""
    }
    
    func authorProfilePicData() -> Data? {
        if let stringURL = comment.snippet?.authorProfileImageUrl,
           let url = URL(string: stringURL),
           let data = try? Data(contentsOf: url) {
            return data
        }
        return nil
    }
    
    var commentText: String {
        if let text = comment.snippet?.textDisplay {
            return "\(text)"
        }
        return ""
    }
    
    var publishTime: String {
        if let time = comment.snippet?.publishedAt {
            return "\(publishedTimeHelper(time: time)) ago"
        }
        return ""
    }
    
    var authorName: String {
        if let name = comment.snippet?.authorDisplayName {
            return name
        }
        return ""
    }

    var profilePicURL: String {
        if let name = comment.snippet?.authorProfileImageUrl {
            return name
        }
        return ""
    }
}
