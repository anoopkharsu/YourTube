//
//  Replies.swift
//  YourTube
//
//  Created by Anoop Kharsu on 16/12/21.
//

import Foundation
import GoogleAPIClientForREST

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
