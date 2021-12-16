//
//  Comments.swift
//  YourTube
//
//  Created by Anoop Kharsu on 04/12/21.
//

import Foundation
import GoogleAPIClientForREST


struct Comments {
    var comments = [Comment]()
    var videosID: String
    
    func fetchCommentResource(pageToken: String?, callBack: @escaping ( GTLRYouTube_CommentThreadListResponse ) -> Void){
        let query = GTLRYouTubeQuery_CommentThreadsList.query(withPart: ["snippet", "replies", "id"])
        query.pageToken = pageToken
        query.videoId = videosID
        query.textFormat = "plainText"
        query.order = "relevance"
        Home.service.executeQuery(query) { response, _, error in
            if let error = error {
                print(error,"rrr")
                return
            }
            
            if let comments = response.fetchedObject as? GTLRYouTube_CommentThreadListResponse {
                callBack(comments)
            }
        }
    }
    
}

struct Comment {
    let commentThread: GTLRYouTube_CommentThread?
    let comment: GTLRYouTube_Comment?
    
    var id: String {
        if let id = commentThread?.identifier {
            return id
        }
        return ""
    }
    
    func authorProfilePicData() -> Data? {
        if let stringURL = comment?.snippet?.authorProfileImageUrl,
           let url = URL(string: stringURL),
           let data = try? Data(contentsOf: url) {
            return data
        }
        return nil
    }
    
    var repliesCount: String {
        if let repliesCount = commentThread?.snippet?.totalReplyCount {
            return "\(viewCountConverter(views: Int(truncating: repliesCount)))"
        }
//        commentThread?.replies
        return ""
    }
    
    var repliesCountInt: Int {
        if let repliesCount = commentThread?.snippet?.totalReplyCount {
            return Int(truncating: repliesCount)
        }
//        commentThread?.replies
        return 0
    }
    
    var likesCount: String {
        if let likeCount = comment?.snippet?.likeCount {
            return "\(viewCountConverter(views: Int(truncating: likeCount)))"
        }
        return ""
    }
    
    var commentText: String {
        if let text = comment?.snippet?.textDisplay {
            return "\(text)"
        }
        return ""
    }
    
    var publishTime: String {
        if let time = comment?.snippet?.publishedAt {
            return "\(publishedTimeHelper(time: time)) ago"
        }
        return ""
    }
    
    var authorName: String {
        if let name = comment?.snippet?.authorDisplayName {
            return name
        }
        return ""
    }

    var profilePicURL: String {
        if let name = comment?.snippet?.authorProfileImageUrl {
            return name
        }
        return ""
    }
    
    var url: String {
        if let url = comment?.snippet?.authorProfileImageUrl {
            return url
        }
        return ""
    }
    
}
