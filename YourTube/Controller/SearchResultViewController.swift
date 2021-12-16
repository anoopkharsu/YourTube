//
//  SearchResultViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 21/11/21.
//

import UIKit
import GoogleAPIClientForREST

class SearchResultViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var resultTableView: UITableView!
    
    @IBOutlet weak var searchBarView: UISearchBar!
    @IBOutlet weak var backButton: UIButton!
    var status = "search"
    var searchText = ""
    var results = SearchResults()
    var searchString: String? = nil
    var token: String?
    var going = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarView.text = searchText
        results.setApiKey("AIzaSyCnwV6m5iEzsHbkpQy2dm_S4oKCSZiDf5Q")
        searchBarView.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoPresenter")
        resultTableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
        if let searchString = searchString {
            getTen(searchString)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if !going {
            going = true
            navigationController?.popViewController(animated: true)
        }
        
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        status = "search"
        navigationControllerDelegate = navigationController?.delegate as? NavigationControllerDelegate
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 0.5) {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    var startX: CGFloat = 0
    var navigationControllerDelegate: NavigationControllerDelegate?
    
    @IBAction func leftSwipeGestureHandler(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
       
      
        let percent = min(1, max(0, (translation.x - startX)/400))
        
        switch sender.state {
          case .began:
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
    
    func getVideos(index: IndexPath) {
        DispatchQueue.global().async {
            self.results.searchData[index.item].getThumbnailImageData { thumbnailImageData, channelImageData in
                DispatchQueue.main.async {
                    self.results.searchData[index.item].setData(thumbnailImageData, channelImageData)
                    self.resultTableView.reloadRows(at: [index], with: .none)
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = resultTableView.indexPathForSelectedRow {
            if results.searchData[index.item].isChannel {
                if  let channelController = storyboard?.instantiateViewController(identifier: "ChannelViewController") as? ChannelSectionViewController {
                    let channel = results.searchData[index.item]
                    if let id = channel.channelId {
                        channelController.channelId = id
                        channelController.channel = VideoWithData(
                            item: channel.videoData ?? GTLRYouTube_Video(),
                            thumbnailData: channel.videoThumbnailData,
                            channel: channel.channel,
                            channelImageData: channel.channelImageData)
                        navigationController?.pushViewController(channelController, animated: true)
                    }
                }
            } else {
                if let videoController = storyboard?.instantiateViewController(identifier: "VideoDetailViewController") as? VideoDetailViewController {
                    status = "video"
                    let data = results.searchData[index.item]
                    videoController.videoData = VideoWithData(
                        item: data.videoData!,
                        thumbnailData: data.videoThumbnailData,
                        channel: data.channel,
                        channelImageData: data.channelImageData)
                    
                    navigationController?.pushViewController(videoController, animated: true)
                }
            }
            
        }
    }
    
    func getTen(_ string: String) {
        DispatchQueue.global().async {
            self.results.fetchVideosResource(queryString: string,token: self.token){ response, _ , error in
                if let res = response.fetchedObject as? GTLRYouTube_SearchListResponse {
                    self.token = res.nextPageToken
                    
                    res.items?.forEach({ video in
                        if video.identifier?.kind != "youtube#playlist" {
                            self.results.searchData.append(SearchResultWithData(item: video))
                        }
                    })
                    self.results.fetchChannelResource { response, _, _ in
                        if let channels = response.fetchedObject as? GTLRYouTube_ChannelListResponse {
                            channels.items?.forEach({ channel in
                                if let id = channel.identifier {
                                    self.results.channels[id] = channel
                                }
                            })
                            self.results.setChannelData()
                        }
                        
                        self.results.fetchResource { response, _, _ in
                            if let videos = response.fetchedObject as? GTLRYouTube_VideoListResponse {
                                videos.items?.forEach({ channel in
                                    if let id = channel.identifier {
                                        self.results.videos[id] = channel
                                    }
                                })
                                self.results.setVideoData()
                            }
                            DispatchQueue.main.async {
                                self.resultTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        if let index = sender.view?.tag, let channelController = storyboard?.instantiateViewController(identifier: "ChannelViewController") as? ChannelViewController {
            let channel = results.searchData[index]
            
            if let id = channel.channelId {
                
                channelController.channelId = id
                channelController.channel = VideoWithData(
                    item: channel.videoData!,
                    thumbnailData: channel.videoThumbnailData,
                    channel: channel.channel,
                    channelImageData: channel.channelImageData)
                navigationController?.pushViewController(channelController, animated: true)
            }
        }
    }
    
}


extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.searchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if results.searchData[indexPath.item].isChannel {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath)
            if let cell = cell as? ChannelTableViewCell {
                let channel = results.searchData[indexPath.item]
                
                cell.channelImageView.image = nil
                cell.channelNameLabel.text = channel.title
                cell.subscribersCountLabel.text = channel.subscriberCount
                cell.videoCountLabel.text = channel.channelVideoCount
                if  channel.channelImageData == nil {
                    getVideos(index: indexPath)
                } else {
                    cell.channelImageView.image = UIImage(data: channel.channelImageData!)
                }
            }
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPresenter", for: indexPath)
        if let cell = cell as? VideoTableViewCell {
            let video = results.searchData[indexPath.item]
            cell.titleLabel.text = video.title
            cell.id = video.id
            cell.viewCounts.text = video.videoViewCounts
            cell.publishedTime.text = video.publishedTime
            cell.channelName.text = video.channelName
            cell.durationTimeLabelView.text = video.durationString
            cell.channelImage.image = nil
            cell.thumbnailImage.image = nil
            cell.channelImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            cell.channelImage.tag = indexPath.item
            if video.videoThumbnailData == nil || video.channelImageData == nil{
                getVideos(index: indexPath)
            } else {
                cell.thumbnailImage.image = UIImage(data: video.videoThumbnailData!)
                cell.channelImage.image = UIImage(data: video.channelImageData!)
                
            }
        }
        return cell
    }
}



extension SearchResultViewController: TransitionInfoProtocol {
    func animationHeper() {
        navigationController?.navigationBar.transform = .identity
    }
    func viewsToAnimate() -> [UIView] {
        switch status {
        case "search":
            return [backButton, searchBarView]
        case "video":
            if let index = resultTableView.indexPathForSelectedRow {
                if let cell = resultTableView.cellForRow(at: index) as? VideoTableViewCell {
                    return [cell.thumbnailImage, cell.channelImage, cell.titleLabel, cell.viewCounts, cell.publishedTime, cell.durationTimeLabelView]
                }
            }
        case "channel":
           return []
                
        default:
            return []
        }
        
       return []
    }
    
    func copyForView(_ subView: UIView, index: Int) -> UIView {
        switch status {
        case "search":
                switch index {
                case 0:
                    let button = UIButton()
                    let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)
                    button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
                    button.setPreferredSymbolConfiguration(.init(pointSize: 21, weight: .bold), forImageIn: .normal)
                    
                    
                    return button
                case 1:
                    let bar = UISearchBar()
                    bar.text = searchBarView.text
                    bar.searchBarStyle = .minimal
                    return bar
                default:
                    return UIView()
                }
        case "video":
            if let indexPath = resultTableView.indexPathForSelectedRow {
                if let cell = resultTableView.cellForRow(at: indexPath) as? VideoTableViewCell {
                    switch index {
                    case 0:
                        return UIImageView(image: cell.thumbnailImage.image)
                    case 1:
                        let image = UIImageView(image: cell.channelImage.image)
                        image.clipsToBounds = true
                        image.layer.cornerRadius = 20
                        return image
                    case 2:
                        let label = UILabel()
                          label.numberOfLines = 0
                          label.text = cell.titleLabel.text
                          label.font = cell.titleLabel.font
                          label.sizeToFit()
                        return label
                    case 3:
                        let label = UILabel()
                          label.numberOfLines = 0
                          label.text = cell.viewCounts.text
                          label.font = cell.viewCounts.font
                        label.textColor = .secondaryLabel
                          label.sizeToFit()
                        return label
                    case 4:
                        let label = UILabel()
                          label.numberOfLines = 0
                          label.text = cell.publishedTime.text
                          label.font = cell.publishedTime.font
                            label.textColor = .secondaryLabel
                          label.sizeToFit()
                        return label
                    case 5:
                        let label = EdgeInsetLabel()
                        label.numberOfLines = 0
                        label.textInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
                        label.text = cell.durationTimeLabelView.text
                        label.font = cell.durationTimeLabelView.font
                        label.textColor = UIColor(named: "TimeTextColor")
                        label.backgroundColor = UIColor(named: "TimeLabelBackground")
                        
                        label.sizeToFit()
                        return label
                    default:
                        return UIView()
                    }
                }
            }
        case "channel":
            return UIView()
        default:
            return UIView()
        }
        
        return UIView()
    }
}
