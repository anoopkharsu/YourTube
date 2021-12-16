//
//  SearchResults.swift
//  YourTube
//
//  Created by Anoop Kharsu on 22/11/21.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

struct SearchResults {
    var searchData = [SearchResultWithData]()
    var channels = [String : GTLRYouTube_Channel]()
    var videos = [String : GTLRYouTube_Video]()
    func setApiKey(_ key: String) {
        Home.service.apiKey = key
    }
    
    func fetchVideosResource(queryString: String, token: String?, callBack: @escaping ( GTLRServiceTicket, Any?, Error?) -> Void) {
        let query = GTLRYouTubeQuery_SearchList.query(withPart: ["snippet"])
        query.q = queryString
        query.maxResults = 30
        Home.service.executeQuery(query, completionHandler: callBack)
    }
    
    mutating func setChannelData(){
        for i in searchData.indices {
            if searchData[i].channel == nil, let id = searchData[i].item.snippet?.channelId  {
                searchData[i].channel = channels[id]
            }
        }
    }
    
    mutating func setVideoData(){
        for i in searchData.indices {
            if searchData[i].videoData == nil, !searchData[i].isChannel {
                searchData[i].videoData = videos[searchData[i].id]
            }
        }
    }

    func fetchChannelResource( callBack: @escaping ( GTLRServiceTicket, Any?, Error?) -> Void) {
        var ids = [String]()
        searchData.forEach { video in
            if let id = video.item.snippet?.channelId, channels[id] == nil {
                ids.append(id)
            }
        }
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["snippet","contentDetails","statistics","brandingSettings"])
        query.identifier = ids
        Home.service.executeQuery(query, completionHandler: callBack)
    }
    
    func fetchResource(callBack: @escaping ( GTLRServiceTicket, Any?, Error?) -> Void){
        var ids = [String]()
        searchData.forEach { data in
            if  !data.isChannel && videos[data.id] == nil {
                ids.append(data.id)
            }
        }
        let query = GTLRYouTubeQuery_VideosList.query(withPart: ["snippet","contentDetails","statistics"])
        query.identifier = ids
        Home.service.executeQuery(query, completionHandler: callBack)
    }
    
}


struct SearchResultWithData {
    var item: GTLRYouTube_SearchResult
    var channel: GTLRYouTube_Channel? = nil
    var videoData: GTLRYouTube_Video? = nil
    
    var videoThumbnailData: Data? = nil
    var channelImageData: Data? = nil
    var title: String {
        item.snippet?.title ?? ""
    }
    
    var durationString: String {
        if var duration = videoData?.contentDetails?.duration {
            duration = duration.replacingOccurrences(of: "PT", with: "")
            duration = duration.replacingOccurrences(of: "H", with: ":")
            duration = duration.replacingOccurrences(of: "M", with: ":")
            duration = duration.replacingOccurrences(of: "S", with: "")
            
            return duration
        }
        return ""
    }
    
    var isChannel:Bool {
        item.identifier?.kind == "youtube#channel"
    }
    
    var channelId: String? {
        channel?.identifier
    }
    
    var id: String {
        if isChannel {
            return item.identifier?.channelId ?? ""
        }
        return item.identifier?.videoId ?? ""
    }
    
    var videoViewCounts: String {
        if let counts = videoData?.statistics?.viewCount {
            return "\(viewCountConverter(views: Int(truncating: counts))) views"
        }
        return ""
    }
    var videoLikesCount: String {
        if let likeCount = videoData?.statistics?.likeCount {
            return "\(viewCountConverter(views: Int(truncating: likeCount)))"
        }
        return ""
    }
    var videoDislikesCount: String {
        if let dislikeCount = videoData?.statistics?.dislikeCount {
            return "\(viewCountConverter(views: Int(truncating: dislikeCount)))"
        }
        return ""
    }
    
    var publishedTime: String {
        if let time = item.snippet?.publishedAt {
            return "\(publishedTimeHelper(time: time)) ago"
        }
        return ""
    }
    
    var subscriberCount: String {
        if let dislikeCount = channel?.statistics?.subscriberCount {
            return "\(viewCountConverter(views: Int(truncating: dislikeCount))) subscribers"
        }
        return ""
    }
    var channelName: String {
        if let name = item.snippet?.channelTitle {
            return name
        }
        return ""
    }
    
    var channelVideoCount: String {
        if let videoCount = channel?.statistics?.videoCount {
            return "\(viewCountConverter(views: Int(truncating: videoCount))) videos"
        }
        return ""
    }
    
    func getThumbnailImageData(getData:@escaping (Data, Data) -> Void) {
        if let urlString = item.snippet?.thumbnails?.medium?.url,
            let url = URL(string: urlString ),
            let thumbnailImageData = try? Data(contentsOf: url) {
            
            if let urlString = channel?.snippet?.thumbnails?.medium?.url,
                let url = URL(string: urlString ),
                let channelImageData = try? Data(contentsOf: url) {
               getData(thumbnailImageData, channelImageData)
            }
        }
    }
    mutating func setData(_ thumbnailData: Data,_ channelImageData: Data) {
        self.videoThumbnailData = thumbnailData
        self.channelImageData = channelImageData
    }
    
}

