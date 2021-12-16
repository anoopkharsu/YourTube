//
//  VideoWithData.swift
//  YourTube
//
//  Created by Anoop Kharsu on 09/11/21.
//

import Foundation
import GoogleAPIClientForREST

struct VideoWithData {
    let item: GTLRYouTube_Video
    var thumbnailData: Data?
    var channel: GTLRYouTube_Channel? = nil
    var channelImageData: Data? = nil
    var channelBannerImageData: Data? = nil
    
   
    var commentCountInt: Int {
        if let counts = item.statistics?.commentCount {
            return Int(truncating: counts)
        }
        return 0
    }
    
    var title: String {
        item.snippet?.title ?? ""
    }
    func getBannerImageData() -> Data? {
        if let urlString = channel?.brandingSettings?.image?.bannerExternalUrl,
            let url = URL(string: urlString ),
            let data = try? Data(contentsOf: url) {
          return data
        }
        return nil
    }
    var channelVideoCount: String {
        if let videoCount = channel?.statistics?.videoCount {
            return "\(viewCountConverter(views: Int(truncating: videoCount))) videos"
        }
        return ""
    }
    
    var commentsCount: String {
        if let commentCount = item.statistics?.commentCount {
            return "\(viewCountConverter(views: Int(truncating: commentCount)))"
        }
        return ""
    }
    
    var channelId: String? {
        channel?.identifier
    }
    var id: String {
        return item.identifier ?? ""
    }
    var imageHeight: CGFloat {
        CGFloat(truncating: item.snippet?.thumbnails?.medium?.height ?? 0)
    }
    var viewCounts: String {
        if let counts = item.statistics?.viewCount {
            return "\(viewCountConverter(views: Int(truncating: counts))) views"
        }
        return ""
    }
    var likesCount: String {
        if let likeCount = item.statistics?.likeCount {
            return "\(viewCountConverter(views: Int(truncating: likeCount)))"
        }
        return ""
    }
    var dislikesCount: String {
        if let dislikeCount = item.statistics?.dislikeCount {
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
        if let name = channel?.snippet?.title {
            return name
        }
        return ""
    }
    
    var durationString: String {
        if var duration = item.contentDetails?.duration {
            duration = duration.replacingOccurrences(of: "PT", with: "")
            var h = ""
            var m = ""
            var s = ""
            var container = ""
            duration.forEach { char in
                if char == "H" {
                    h = container
                    container = ""
                    return
                }
                if char == "M" {
                    m = container
                    container = ""
                    return
                }
                if char == "S" {
                    s = container
                    container = ""
                    return
                }
                container += String(char)
            }
            
            return "\(h.count == 0 ? "" : h.count == 1 ? "0\(h):" : "\(h):")\(m.count == 1 ? "0" : m.count == 0 ? "00" : "")\(m):\(s.count == 1 ? "0" :s.count == 0  ? "00" : "")\(s)"
        }
        return ""
    }
    
    func setImageToCell(_ cell: VideoTableViewCell) {
        if cell.id != id {
            return
        }
        
        if let data = thumbnailData {
            cell.thumbnailImage.image = UIImage(data: data)
            if let channelImageData = channelImageData {
                cell.channelImage.image = UIImage(data: channelImageData)
            }
        }
    }
    
    func getThumbnailImageData(getData:@escaping (Data, Data) -> Void, noData:@escaping () -> Void) {
        if let urlString = item.snippet?.thumbnails?.medium?.url,
            let url = URL(string: urlString ),
            let thumbnailImageData = try? Data(contentsOf: url) {
            
            if let urlString = channel?.snippet?.thumbnails?.medium?.url,
                let url = URL(string: urlString ),
                let channelImageData = try? Data(contentsOf: url) {
               getData(thumbnailImageData, channelImageData)
            } else {
                noData()
            }
        } else {
            noData()
        }
    }
    mutating func setData(_ thumbnailData: Data,_ channelImageData: Data) {
        self.thumbnailData = thumbnailData
        self.channelImageData = channelImageData
    }
    mutating func setChannel(_ channel: GTLRYouTube_Channel?,_ channelImageData: Data?) {
        self.channel = channel
        self.channelImageData = channelImageData
    }
}







func viewCountConverter(views: Int ) -> String{
    var intValue = views
    var value = ""
    
    switch intValue {
    case 0...999:
        return "\(intValue)"
    case 1000...999999:
        intValue = intValue / 1000 //k
        return "\(intValue)K"
    case 1000000...999999999:
        intValue = intValue / 100000//M
        value = "M"
    default:
        intValue = intValue / 100000000 //B
        value = "B"
    }
    
    return "\(Double(intValue) / 10)\(value)"
}


func publishedTimeHelper( time: GTLRDateTime) -> String{
    let sec = (Date().timeIntervalSince1970 - time.date.timeIntervalSince1970)
    switch sec {
    case 0...3600:
        let time = Int(sec / 60)
            if time <= 1 {
                return "1 min"
            }
            return "\(time) mins"
        
    case 3601...86400:
        let time = Int(sec / 3600)
        if time <= 1 {
                return "1 hour"
            }
            return "\(time) hours"
        
    case 86401...604800:
        let time = Int(sec / 86400)
        if time <= 1 {
                return "1 day"
            }
            return "\(time) days"
        
    case 604801...2592000:
        let time = Int(sec / 604800)
        if time <= 1 {
                return "1 week"
            }
            return "\(time) weeks"
        
    case 2592001...31104000:
        let time = Int(sec / 2592000)
            if time <= 1 {
                return "1 month"
            }
            return "\(time) months"
        
    default:
        let time = Int(sec / 31104000)
            if time == 1 {
                return "1 year"
            }
            return "\(time) years"
        
    }
}

