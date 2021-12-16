//
//  ChannelUploadsViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 11/12/21.
//

import UIKit
import GoogleAPIClientForREST

class ChannelUploadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var channel: VideoWithData? = nil
    var uploadsPlayListId = ""
    var uploads = Uploads()
    @IBOutlet weak var tableView: UITableView!
    var uploadId: String? {
        if let id = channel?.channel?.contentDetails?.relatedPlaylists?.uploads {
            return id
        }
        return nil
    }
    var token: String? = nil
    
    func getViewCount(item: GTLRYouTube_PlaylistItem) -> String {
        if let id = item.snippet?.resourceId?.videoId {
            if let video = uploads.videos[id] {
                if let likeCount = video.statistics?.viewCount {
                    return "\(viewCountConverter(views: Int(truncating: likeCount))) views"
                }
            }
        }
        return ""
    }
    
    func getDurationOfVideo(item: GTLRYouTube_PlaylistItem) -> String {
        if let id = item.snippet?.resourceId?.videoId {
            if let video = uploads.videos[id] {
                if var duration = video.contentDetails?.duration {
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
            }
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PlayListTableViewCell", bundle: nil), forCellReuseIdentifier: "PlayListCell")
        getItems()
    }
    
    var working = false
    func getItems(){
        if working {
            return
        }
        working = true
        if let id = uploadId {
            DispatchQueue.global().async {[self] in
                uploads.getUploadItems(token: token, id: id) { res in
                    print(res.items?.count ?? 0, "iiffififf")
                    self.token = res.nextPageToken
                    DispatchQueue.main.async {
                        self.uploads.addItems(i: res.items ?? [])
                        self.tableView.reloadData()
                        let ids = self.uploads.ids
                        DispatchQueue.global().async {
                            self.uploads.getVideos(ids: ids) { videos in
                                DispatchQueue.main.async {
                                    self.uploads.addVideos(v: videos.items ?? [])
                                    self.tableView.reloadData()
                                    working = false
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    var thumbnailImages = [String: Data]()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.isHidden = false
        }
    }
}

struct Uploads {
    
    var videos = [String: GTLRYouTube_Video]()
    var items = [GTLRYouTube_PlaylistItem]()
    var ids: [String] {
        var ids = [String]()
        items.forEach { item in
            if item.status?.privacyStatus == "public", let id = item.snippet?.resourceId?.videoId, videos[id] == nil {
                ids.append(id)
            }
        }
        return ids
    }
    
    mutating func addItems( i: [GTLRYouTube_PlaylistItem]){
        items += i
    }
    
    mutating func addVideos( v: [GTLRYouTube_Video]){
        v.forEach { video in
            videos[video.identifier!] = video
        }
    }
    
    func getUploadItems(token: String?, id: String,callBack: @escaping ( GTLRYouTube_PlaylistItemListResponse ) -> Void){
        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet","contentDetails","status"])
        query.maxResults = 20
        query.playlistId = id
        query.pageToken = token
        Home.service.executeQuery(query) { response, _, error in
            if let error = error {
                print(error, "uploadPlaylist error")
                return
            }
            if let res = response.fetchedObject as? GTLRYouTube_PlaylistItemListResponse {
                callBack(res)
            }
        }
        
    }
    
    
    func getVideos(ids: [String],callBack: @escaping ( GTLRYouTube_VideoListResponse) -> Void){
        let query = GTLRYouTubeQuery_VideosList.query(withPart: ["snippet","contentDetails","statistics"])
        query.identifier = ids
        query.maxResults = 20
        Home.service.executeQuery(query) { response, _, error in
            if let error = error {
                print(error, "uploadPlaylist error")
                return
            }
            if let res = response.fetchedObject as? GTLRYouTube_VideoListResponse {
                callBack(res)
            }
        }
    }
}

//MARK: - Additional function (Supporting)
extension ChannelUploadsViewController {
    
}

extension ChannelUploadsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uploads.items.count
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let videoController = storyboard?.instantiateViewController(identifier: "VideoDetailViewController") as? VideoDetailViewController {
            let item = uploads.items[indexPath.item]
            if let id = item.snippet?.resourceId?.videoId,  let video = uploads.videos[id], let data = getImageData(item: item,index: indexPath){
                videoController.videoData = VideoWithData(
                    item: video,
                    thumbnailData: data,
                    channel: channel?.channel,
                    channelImageData: channel?.channelImageData)
                videoController.prive = "channel"
                navigationController?.pushViewController(videoController, animated: true)
            }
        }
        
    }
    func getImageData(item: GTLRYouTube_PlaylistItem, index: IndexPath) -> Data? {
        if let id = item.snippet?.resourceId?.videoId {
            //            if let video = uploads.videos[id] {
            
            if let data = thumbnailImages[id] {
                return data
            } else {
                if let video = uploads.videos[id] {
                    DispatchQueue.global().async {
                        if let urlString = video.snippet?.thumbnails?.medium?.url,
                           let url = URL(string: urlString ),
                           let thumbnailImageData = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                self.thumbnailImages[id] = thumbnailImageData
                                self.tableView.reloadRows(at: [index], with: .none)
                            }
                        }
                    }
                } else {
                    //                    if !finding {
                    //                        DispatchQueue.global().async {
                    //                            self.getRemaining()
                    //                        }
                    //                    }
                }
            }
        }
        
        return nil
    }
    
    func getItemPublishedDate(item: GTLRYouTube_PlaylistItem) -> String {
        if let time = item.contentDetails?.videoPublishedAt {
            return "\(publishedTimeHelper(time: time)) ago"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListCell", for: indexPath)
        let item = uploads.items[indexPath.item]
        
        if let cell = cell as? PlayListTableViewCell {
            cell.videoTitleLabelView.text = item.snippet?.title ?? ""
            cell.publishTimeLabelView.text = getItemPublishedDate(item: item)
            cell.viewCountLabelView.text = getViewCount(item: item)
            let string = getDurationOfVideo(item: item)
            if string.count == 0 {
                cell.durationTimeLabelView.isHidden = true
            } else {
                cell.durationTimeLabelView.isHidden = false
                cell.durationTimeLabelView.text = string
            }
            
            if let data = getImageData(item: item,index: indexPath) {
                cell.videoThumbnailImageView.image = UIImage(data: data)
            } else {
                cell.videoThumbnailImageView.image = nil
            }
            
            if indexPath.item > uploads.items.count - 3 {
                getItems()
            }
            
        }
        return cell
    }
}


extension ChannelUploadsViewController: TransitionInfoProtocol {
    
    func animationHeper() {
        navigationController?.navigationBar.transform = .identity
    }
    func viewsToAnimate() -> [UIView] {
        if let index = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: index) as? PlayListTableViewCell {
                return [cell.videoThumbnailImageView,  cell.videoTitleLabelView, cell.viewCountLabelView, cell.publishTimeLabelView, cell.durationTimeLabelView]
            }
        }
        return []
    }
    
    func copyForView(_ subView: UIView, index: Int) -> UIView {
        if let indexPath = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: indexPath) as? PlayListTableViewCell {
                switch index {
                case 0:
                    return UIImageView(image: cell.videoThumbnailImageView.image)
                    
                case 1:
                    let label = UILabel()
                    label.numberOfLines = 0
                    label.text = cell.videoTitleLabelView.text
                    label.font = cell.videoTitleLabelView.font
                    label.sizeToFit()
                    return label
                case 2:
                    let label = UILabel()
                    label.numberOfLines = 0
                    label.text = cell.viewCountLabelView.text
                    label.font = cell.viewCountLabelView.font
                    label.textColor = .secondaryLabel
                    label.sizeToFit()
                    return label
                case 3:
                    let label = UILabel()
                    label.numberOfLines = 0
                    label.text = cell.publishTimeLabelView.text
                    label.font = cell.publishTimeLabelView.font
                    label.textColor = .secondaryLabel
                    label.sizeToFit()
                    return label
                case 4:
                    let label = EdgeInsetLabel()
                    label.numberOfLines = 0
                    label.textInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
                    label.text = cell.durationTimeLabelView.text
                    label.font = cell.durationTimeLabelView.font
                    label.textColor = UIColor(named: "TimeTextColor")
                    label.backgroundColor = .black
                    label.sizeToFit()
                    return label
                default:
                    return UIView()
                }
            }
        }
        return UIView()
    }
    
    
}
