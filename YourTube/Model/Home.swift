//
//  Home.swift
//  YourTube
//
//  Created by Anoop Kharsu on 07/11/21.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

struct Home {
    private let signInConfig = GIDConfiguration(clientID: "760966996889-fqo52qpq16p4ef1j1sk4tc5p27s2j0v8.apps.googleusercontent.com")
    static let service = GTLRYouTubeService()
    var delegate: HomeHandler?
    var videos = [GTLRYouTube_SearchResult]()
    var popularVideos = [VideoWithData]()
    var channels = [String : GTLRYouTube_Channel]()
    
    
    var user: GIDGoogleUser? {
        didSet {
            delegate?.userSignedIn()
        }
    }
    var signedIn: Bool {
        GIDSignIn.sharedInstance.hasPreviousSignIn()
    }
    
    func setApiKey(_ key: String) {
        Home.service.apiKey = key
    }
    
    mutating func setVideos( items: [GTLRYouTube_SearchResult]) {
        videos += items
        print(videos.count)
        self.delegate?.newVideosAdd()
    }
    
    func getMostPopularVideos(token: String?,callBack: @escaping ( GTLRServiceTicket, Any?, Error?) -> Void){
        let query = GTLRYouTubeQuery_VideosList.query(withPart: ["snippet","contentDetails","statistics"])
        query.chart = "mostPopular"
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            query.regionCode = countryCode
        }
        query.maxResults = 20
        query.pageToken = token
        Home.service.executeQuery(query, completionHandler: callBack)
    }
    
    func signInUser( controller: UIViewController,
        successCallBack:@escaping (GIDGoogleUser) -> Void,
        errorCallBack:@escaping (Error?) -> Void){
       
            GIDSignIn.sharedInstance.signIn(with: self.signInConfig, presenting: controller) { user, error in
                if let user = user {
                    successCallBack(user)
                } else {
                    errorCallBack(error)
                }
                
            }
    }
    
   

    mutating func setChannelData(){
        for i in popularVideos.indices {
            if popularVideos[i].channel == nil, let id = popularVideos[i].item.snippet?.channelId  {
                popularVideos[i].channel = channels[id]
            }
        }
    }
    
    func fetchChannelResource(callBack: @escaping ( GTLRServiceTicket, Any?, Error?) -> Void) {
        var ids = [String]()
        popularVideos.forEach { video in
            if let id = video.item.snippet?.channelId, channels[id] == nil {
                ids.append(id)
            }
        }
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["snippet","contentDetails","statistics","brandingSettings"])
        query.identifier = ids
        
        Home.service.executeQuery(query, completionHandler: callBack)
    }
    
}

protocol HomeHandler {
    func userSignedIn()
    func newVideosAdd()
}












/*
 https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,channelTitle,thumbnails))&order=viewCount&q=\(searchBar.text)&type=video&maxResults=25&key=\(apiKey)
  */

//@objc func displayResultWithTicket(
//    ticket: GTLRServiceTicket,
//    finishedWithObject response : GTLRYouTube_SearchListResponse,
//    error : NSError?) {
//
//    if let error = error {
//        print(error, "response")
//        showAlert(title: "Error", message: error.localizedDescription)
//        return
//    }
//        print(response.items?.count, "response")
////        var outputText = ""
////        if let channels = response.items, !channels.isEmpty {
////            let channel = response.items![0]
////            let title = channel.snippet!.title
////            let description = channel.snippet?.descriptionProperty
////            let viewCount = channel.statistics?.viewCount
////            outputText += "title: \(title!)\n"
////            outputText += "description: \(description!)\n"
////            outputText += "view count: \(viewCount!)\n"
////        }
////        output.text = outputText
//
//    }
