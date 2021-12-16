//
//  ViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 06/11/21.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit


class HomeViewController: UIViewController {
    private let navigationControllerDelegate = NavigationControllerDelegate()
    var homeDataProvider = Home()
    var imageDataLoadedForIndex = [Int: Bool]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusBarHeight: NSLayoutConstraint!
    var nextPageToken: String?
    var searchBarButtom: UIBarButtonItem? = nil
    var lastValueOfScrollViewOffest: CGFloat = 0
    var valueNavBarMove: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoPresenter")
        homeDataProvider.setApiKey("AIzaSyCnwV6m5iEzsHbkpQy2dm_S4oKCSZiDf5Q")
        homeDataProvider.delegate = self
        navigationController?.delegate = navigationControllerDelegate
        
        searchBarButtom =  UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchButtn))
        navigationItem.rightBarButtonItems = [ searchBarButtom!]
        DispatchQueue.global().async {
            self.fetchVideos()
        }
        
    }
    
    
    @objc func searchButtn() {
        performSegue(withIdentifier: "ToSearchScreen", sender: self)
    }
    
    var inTheWork = false
    func fetchVideos() {
        if inTheWork {
            return
        }
        inTheWork = true
        if homeDataProvider.popularVideos.count > 50 {
            return
        }
        homeDataProvider.getMostPopularVideos(token: self.nextPageToken){ response, _ , error in
            if error != nil {
                
                self.navigationController?.navigationItem.prompt = "Error getting videos"
            }
            if let res = response.fetchedObject as? GTLRYouTube_VideoListResponse {
                self.nextPageToken = res.nextPageToken
                DispatchQueue.main.async {
                    res.items?.forEach({ video in
                        self.homeDataProvider.popularVideos.append(VideoWithData(item: video, thumbnailData: nil))
                    })
                    self.tableView.reloadData()
                    DispatchQueue.global().async {
                        self.homeDataProvider.fetchChannelResource { response, _, _ in
                            DispatchQueue.main.async {
                                if let channels = response.fetchedObject as? GTLRYouTube_ChannelListResponse {
                                    channels.items?.forEach({ channel in
                                        if let id = channel.identifier {
                                            self.homeDataProvider.channels[id] = channel
                                        }
                                    })
                                    self.homeDataProvider.setChannelData()
                                }
                                
                                self.tableView.reloadData()
                                self.inTheWork = false
                            }
                        }
                    }
                    
                }
                
            }
        }
        
        
    }
    
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusBarHeight.constant = view.safeAreaInsets.top - (navigationController?.navigationBar.frame.height ?? 0)
        
    }
    
}


extension HomeViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let topSafeArea = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + topSafeArea
        
        if offset >= 0 {
            switch offset {
            case 0..<lastValueOfScrollViewOffest:
                if valueNavBarMove > 0 {
                    valueNavBarMove += offset - lastValueOfScrollViewOffest
                    navigationController?.navigationBar.transform = .init(translationX: 0, y: -valueNavBarMove)
                } else {
                    valueNavBarMove = 0
                    navigationController?.navigationBar.transform = .identity
                }
                
                lastValueOfScrollViewOffest = offset
                
            case lastValueOfScrollViewOffest...CGFloat.infinity:
                if valueNavBarMove < topSafeArea {
                    valueNavBarMove += offset - lastValueOfScrollViewOffest
                    navigationController?.navigationBar.transform = .init(translationX: 0, y: -valueNavBarMove)
                }
                lastValueOfScrollViewOffest = offset
                
            default:
                lastValueOfScrollViewOffest = offset
            }
        } else {
            navigationController?.navigationBar.transform = .identity
        }
        
        
    }
    
}


extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return homeDataProvider.popularVideos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if homeDataProvider.popularVideos[indexPath.item].thumbnailData != nil {
            performSegue(withIdentifier: "VideoDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backButtonTitle = "Back"
        if segue.identifier == "VideoDetail" , let destination = segue.destination as? VideoDetailViewController {
            if let index = tableView.indexPathForSelectedRow {
                destination.videoData = homeDataProvider.popularVideos[index.item]
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.tableView.reloadData()
    }
    
    func getVideos(index: IndexPath) {
        if imageDataLoadedForIndex[index.item] != true {
            imageDataLoadedForIndex[index.item] = true
            DispatchQueue.global(qos: .background).async {
                self.homeDataProvider.popularVideos[index.item].getThumbnailImageData { thumbnailImageData, channelImageData in
                    DispatchQueue.main.async {
                        self.homeDataProvider.popularVideos[index.item].setData(thumbnailImageData, channelImageData)
                        self.tableView.reloadRows(at: [index], with: .none)
                        
                    }
                } noData: {
                    DispatchQueue.main.async {
                        self.imageDataLoadedForIndex[index.item] = false
                        self.tableView.reloadRows(at: [index], with: .none)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPresenter", for: indexPath)
        
        if let cell = cell as? VideoTableViewCell {
            let video = homeDataProvider.popularVideos[indexPath.item]

            cell.titleLabel.text = video.title
            
            cell.id = video.id
            cell.viewCounts.text = video.viewCounts
            cell.publishedTime.text = video.publishedTime
            cell.channelName.text = video.channelName
            cell.channelImage.image = nil
            cell.durationTimeLabelView.text = video.durationString
            cell.thumbnailImage.image = nil
            cell.channelImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            cell.channelImage.tag = indexPath.item
            if homeDataProvider.popularVideos[indexPath.item].thumbnailData == nil {
                getVideos(index: indexPath)
            } else {
                homeDataProvider.popularVideos[indexPath.item].setImageToCell(cell)
            }
        }
        if indexPath.item == homeDataProvider.popularVideos.count - 4 {
            DispatchQueue.global(qos: .background).async {
                self.fetchVideos()
            }
        }
        return cell
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        if let index = sender.view?.tag,
            let channelController = storyboard?.instantiateViewController(identifier: "ChannelViewController") as? ChannelViewController {
            let video = homeDataProvider.popularVideos[index]
            if video.channelImageData == nil {
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.transform = .identity
            }
            navigationItem.backButtonTitle = video.channelName
            if let id = video.channelId {
                channelController.channelId = id
                channelController.channel = video
                navigationController?.pushViewController(channelController, animated: true)
            }
        }
    }
}


extension HomeViewController: HomeHandler {
    func userSignedIn() {
        
    }
    
    func newVideosAdd() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.tableView.reloadData()
        }
    }
}


extension HomeViewController: TransitionInfoProtocol {
    func gettttt(){
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["snippet"])
        query.mine = true
        var tokenb = ""
        //        let token = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken
        if let token = GIDSignIn.sharedInstance.currentUser {
            tokenb = token.authentication.accessToken
            
            query.additionalURLQueryParameters = ["access_token": "\(token.authentication.accessToken)"]
            
        } else {
            //            GIDSignIn.sharedInstance.signOut()
            //            GIDSignIn.sharedInstance.addScopes(["https://www.googleapis.com/auth/youtube.upload", "https://www.googleapis.com/auth/youtube"], presenting: self) { user, error in
            //                print(error,"https://www.googleapis.com/auth/youtube")
            //                GIDSignIn.sharedInstance.restorePreviousSignIn { _, _ in
            //
            //                }
            //            }
            //            print("not found", GIDSignIn.sharedInstance.currentUser)
            return
            
        }
        
        //        Home.service.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        Home.service.executeQuery(query) { response, _, error in
            if let error = error {
                print(error,"eeeeeeeeee")
                
                return
            }
            
            if let res = response.fetchedObject as? GTLRYouTube_ChannelListResponse{
                res.items?.forEach({ channel in
                    if let id  = channel.identifier {
                        print(id)
                        if let url = URL(string: "https://youtubeanalytics.googleapis.com/v2/reports?ids=channel%3D%3D\(id)&startDate=2021-10-01&endDate=2021-11-30&metrics=views&dimensions=day&key=AIzaSyCwtFsBB64o20059YQGWWoUClkavzx28n4&access_token=\(tokenb)") {
                            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                                guard let data = data, error == nil else {
                                    return
                                }
                                do{
                                    let firstArray = try JSONSerialization.jsonObject(with: data, options: [])
                                    print(firstArray,"dddddddd")
                                    
                                }
                                catch {
                                    print(error)
                                }
                            }.resume()
                            
                        }
                    } else {
                        print("not found")
                    }
                })
            } else {
                print("not founf")
            }
        }
        
    }
    
    func animationHeper() {
        navigationController?.navigationBar.transform = .identity
    }
    func viewsToAnimate() -> [UIView] {
        if let index = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: index) as? VideoTableViewCell {
                return [cell.thumbnailImage, cell.channelImage, cell.titleLabel, cell.viewCounts, cell.publishedTime, cell.durationTimeLabelView]
            }
        }
        return []
    }
    
    func copyForView(_ subView: UIView, index: Int) -> UIView {
        if let indexPath = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: indexPath) as? VideoTableViewCell {
                
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
                    //                case 3:
                    //                    let label = UILabel()
                    //                      label.numberOfLines = 0
                    //                      label.text = cell.channelName.text
                    //                      label.font = cell.channelName.font
                    //                    label.textColor = .label
                    //                      label.sizeToFit()
                    //                    return label
                    //                    return UIView()
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
        return UIView()
    }
    
    
}




class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
