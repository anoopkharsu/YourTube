//
//  ChannelSection.swift
//  YourTube
//
//  Created by Anoop Kharsu on 29/11/21.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

struct ChannelSection {
    var items: [ChannelData] = []
    var playLists = [String: GTLRYouTube_Playlist]()
    var playListItems = [String: [GTLRYouTube_PlaylistItem]]()
    
    func fetchSectionResource(id: String, callBack: @escaping ( GTLRServiceTicket, Any?, Error?) -> Void) {
        let query = GTLRYouTubeQuery_ChannelSectionsList.query(withPart: ["snippet", "contentDetails"])
        
        query.channelId = id
        Home.service.executeQuery(query, completionHandler: callBack)
    }
    
    func fetchVideosResource(ids:[String], callBack: @escaping ( [GTLRYouTube_Video]) -> Void){
        let query = GTLRYouTubeQuery_VideosList.query(withPart: ["snippet","contentDetails","statistics"])
        query.identifier = ids
        Home.service.executeQuery(query) { res, _, _ in
            if let videos = res.fetchedObject as? GTLRYouTube_VideoListResponse {
                callBack(videos.items ?? [])
            }
        }
    }
    
    mutating func setPlayList(){
        for index in items.indices {
            items[index].playListIds.forEach { id in
                if let item = playLists[id] {
                    items[index].playLists.append(item)
                }
            }
        }
    }
    
    mutating func setPlayListItems(){
        for index in items.indices {
            items[index].playListIds.forEach { id in
                if let item = playListItems[id] {
                    items[index].playListItems += item
                }
            }
        }
    }
    
    func fetchLists( callBack: @escaping ( GTLRServiceTicket, Any?, Error?) -> Void) {
        let query = GTLRYouTubeQuery_PlaylistsList.query(withPart: ["contentDetails", "snippet"])
        var ids = [String]()
        items.forEach { section in
            section.playListIds.forEach({ id in
                if playLists[id] == nil {
                    ids.append(id)
                }
            })
        }
        if ids.isEmpty {
            print("zeroIds")
            return
        }
        query.identifier = ids
        Home.service.executeQuery(query, completionHandler: callBack)
    }
    
    func fetchListItems(id: String, callBack: @escaping ( GTLRServiceTicket, Any?, Error?) -> Void) {
            let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["contentDetails", "snippet", "status"])
            query.playlistId = id
            Home.service.executeQuery(query, completionHandler: callBack)
    }
}

struct ChannelData {
    var item: GTLRYouTube_ChannelSection
    var playLists = [GTLRYouTube_Playlist]()
    var playListIds: [String] {
        item.contentDetails?.playlists ?? []
    }
    var playListItems = [GTLRYouTube_PlaylistItem]()
//    var channelList = []
    var itemsVideoIds: [String] {
        var ids = [String]()
        playListItems.forEach { item in
            if let id = item.contentDetails?.videoId,let status =  item.status?.privacyStatus {
                if ids.count < 4 && status == "public" {
                    ids.append(id)
                }
            }
        }
        return ids
    }
    
   
    
    var sectionTitle: String {
        item.snippet?.title ?? playLists.first?.snippet?.title ?? ""
    }
    
    
    
    func getItemTitle(index: Int) -> String {
        return playListItems[index].snippet?.title ?? ""
    }
    
    func getItemVideoId(index: Int) -> String? {
        return playListItems[index].contentDetails?.videoId
    }
    
    func getItemPublishedDate(index: Int) -> String {
        if let time = playListItems[index].contentDetails?.videoPublishedAt {
            return "\(publishedTimeHelper(time: time)) ago"
        }
        return ""
    }
 
    var sectionDetail: String {
         playLists.first?.snippet?.descriptionProperty ?? ""
    }
//
//    var viewCounts: String {
//        if let counts = item.statistics?.viewCount {
//            return "\(viewCountConverter(views: Int(truncating: counts))) views"
//        }
//        return ""
//    }
    
    mutating func setPlayListItems(items: [GTLRYouTube_PlaylistItem]) {
        playListItems += items
    }
}

