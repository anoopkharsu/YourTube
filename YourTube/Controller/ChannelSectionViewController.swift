//
//  ChannelViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 25/11/21.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class ChannelSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var channel: VideoWithData? = nil
    var channelId = ""
    var otherChannels = [String: GTLRYouTube_Channel]()
    
    var channelSection = ChannelSection()
    @IBOutlet weak var tableView: UITableView!
    var fetched = [String: Bool]()
    var videos = [String: GTLRYouTube_Video]()
    var thumbnailImages = [String: Data]()
    var finding = false
    func getImageData(index: IndexPath) -> Data? {
        if let id = channelSection.items[index.section].getItemVideoId(index: index.item) {
            if let data = thumbnailImages[id] {
                return data
            } else {
                if let video = videos[id] {
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
                    if !finding {
                        DispatchQueue.global().async {
                            self.getRemaining()
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func getRemaining(){
        if finding {
            return
        }
        self.finding = true
        var ids = [String]()
        channelSection.items.forEach { section in
            section.itemsVideoIds.forEach { id in
                if self.videos[id] == nil {
                    ids.append(id)
                }
            }
        }
        self.channelSection.fetchVideosResource(ids: ids) {v in
            v.forEach { video in
                if let id = video.identifier {
                    self.videos[id] = video
                }
            }
            self.channelSection.setPlayListItems()
            DispatchQueue.main.async {
                self.finding = false
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func swipeFromLeftHandler(_ sender: UIScreenEdgePanGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    func getViewCount(index: IndexPath) -> String {
        if let id = channelSection.items[index.section].getItemVideoId(index: index.item) {
            if let video = videos[id] {
                if let likeCount = video.statistics?.viewCount {
                    return "\(viewCountConverter(views: Int(truncating: likeCount))) views"
                }
            }
        }
        return ""
    }
    
    func getDurationOfVideo(index: IndexPath) -> String {
        if let id = channelSection.items[index.section].getItemVideoId(index: index.item) {
            if let video = videos[id] {
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
        print(channelId,"channelIdchannelId")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 40
//        tableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoPresenter")
        self.channelSection.items.append(ChannelData(item: GTLRYouTube_ChannelSection()))
        tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
        tableView.register(UINib(nibName: "PlayListTableViewCell", bundle: nil), forCellReuseIdentifier: "PlayListCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global().async {
            self.getChannelSection()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.isHidden = false
        }
    }
}

//MARK: - Additional function (Supporting)
extension ChannelSectionViewController {
    
    func getChannelBanner(index: IndexPath ) {
        DispatchQueue.global().async {
            if let data = self.channel?.getBannerImageData() {
                DispatchQueue.main.async {
                    self.channel?.channelBannerImageData = data
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getChannelSection(){
        channelSection.fetchSectionResource(id: channelId) { response, _, error in
            if let error = error {
                print(error,"sectionnnnnn")
                return
            }
            if let ff = response.fetchedObject as? GTLRYouTube_ChannelSectionListResponse {
                
                ff.items?.forEach({ section in
                    if section.contentDetails?.channels?.count ?? 0 > 0 || section.contentDetails?.playlists?.count ?? 0 > 0 {
                        self.channelSection.items.append(ChannelData(item: section))
                    }
                   
                })
                self.channelSection.fetchLists { response, _, error in
                    if let error = error {
                        print(error, "listssss")
                        return
                    }
                    if let ll = response.fetchedObject as? GTLRYouTube_PlaylistListResponse {
                        ll.items?.forEach({ playList in
                            if let id = playList.identifier {
                                self.channelSection.playLists[id] = playList
                            }
                        })
                        self.channelSection.setPlayList()
                    }
                    self.getAllItems()
                }
                
            }
            
        }
    }
   
    func getAllItems(){
        channelSection.items.forEach { section in
            section.playListIds.forEach({ id in
                if fetched[id] == nil {
                    fetched[id] = true
                    self.finding = true
                    self.channelSection.fetchListItems(id: id) { res, _, error in
                       
                        if error != nil {
                            self.finding = false
                            return
                        }
                        
                        if let ii = res.fetchedObject as? GTLRYouTube_PlaylistItemListResponse {
                            if let empty = ii.items?.isEmpty, !empty {
                                ii.items?.forEach({ playList in
                                    if let id = playList.snippet?.playlistId {
                                        if self.channelSection.playListItems[id] == nil {
                                            self.channelSection.playListItems[id] = []
                                        }
                                        self.channelSection.playListItems[id]?.append(playList)
                                    }
                                })
                            }
                        }
                        print("safsddfddf")
                        self.channelSection.setPlayListItems()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            DispatchQueue.global().async {
                                self.finding = false
                                self.getAllItems()
                            }
                        }
                        
                    }
                    return
                }
            })
        }
    }
}

//MARK: - TableView section

extension ChannelSectionViewController {
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        if let videoController = storyboard?.instantiateViewController(identifier: "VideoDetailViewController") as? VideoDetailViewController {
            let data = channelSection.items[indexPath.section]
            if let video = videos[data.getItemVideoId(index: indexPath.item)!], let data = getImageData(index: indexPath){
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath)
            if let cell = cell as? ChannelTableViewCell, let channel = channel {
                cell.channelImageView.image = nil
                cell.selectionStyle = .none
                cell.channelNameLabel.text = channel.channelName
                cell.subscribersCountLabel.text = channel.subscriberCount
                cell.videoCountLabel.text = channel.channelVideoCount
                if  channel.channelImageData != nil {
                    cell.channelImageView.image = UIImage(data: channel.channelImageData!)
                }
                if  channel.channelBannerImageData != nil {
                    cell.channelBannerImage.isHidden = false
                    cell.channelBannerImage.image = UIImage(data: channel.channelBannerImageData!)
                } else {
                    getChannelBanner(index: indexPath)
                }
            }
            return cell
        }
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListCell", for: indexPath)
        let item = channelSection.items[indexPath.section]
        
        if let cell = cell as? PlayListTableViewCell {
            cell.videoTitleLabelView.text = item.getItemTitle(index: indexPath.item)
            cell.publishTimeLabelView.text = item.getItemPublishedDate(index: indexPath.item)
            cell.viewCountLabelView.text = getViewCount(index: indexPath)
            let string = getDurationOfVideo(index: indexPath)
            if string.count == 0 {
                cell.durationTimeLabelView.isHidden = true
            } else {
                cell.durationTimeLabelView.isHidden = false
                cell.durationTimeLabelView.text = string
            }
            
            if let data = getImageData(index: indexPath) {
                cell.videoThumbnailImageView.image = UIImage(data: data)
            } else {
                cell.videoThumbnailImageView.image = nil
            }
            
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 || channelSection.items[section].playListItems.count == 0 {
            return nil
        }
        let height: CGFloat = channelSection.items[section].sectionDetail.count == 0 ? 40 : 60
        let customView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: height)))
        let titleLabel = UILabel()
        titleLabel.text = channelSection.items[section].sectionTitle
        let detailLabel = UILabel()
       
        detailLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.font = .preferredFont(forTextStyle: .body)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 2
        detailLabel.sizeToFit()
        detailLabel.text = channelSection.items[section].sectionDetail
        
        titleLabel.clipsToBounds = true
        detailLabel.clipsToBounds = true
        let ddd = UILabel()
        ddd.setContentHuggingPriority(.init(248), for: .vertical)
        ddd.setContentCompressionResistancePriority(.required, for: .vertical)
        let ddd1 = UILabel()
        ddd1.setContentHuggingPriority(.init(249), for: .vertical)
        ddd1.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let stack = UIStackView(arrangedSubviews: [ddd1,titleLabel,detailLabel, ddd])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 0
        detailLabel.sizeToFit()
        
        stack.frame =  CGRect(origin: .init(x: 16, y: 10), size: CGSize(width: view.frame.width - 32, height: height - 5))
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        stack.clipsToBounds = true
        customView.addSubview(stack)
        stack.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
        customView.clipsToBounds = true
        customView.backgroundColor = .systemBackground
        return customView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let playListCount = channelSection.items[section].playListItems.count
        if playListCount == 0 {
            
        }
        return playListCount > 4 ? 4 : playListCount
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        if channelSection.items[section].sectionDetail.count == 0 {
            return channelSection.items[section].playListItems.count == 0 ? 1 : 40
        }
        return channelSection.items[section].playListItems.count == 0 ? 1 : 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return channelSection.items.count
    }
    
}


extension ChannelSectionViewController: TransitionInfoProtocol {
   
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
