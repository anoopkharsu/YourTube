//
//  SearchViewController.swift
//  YourTube
//
//  Created by Anoop Kharsu on 20/11/21.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestedSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCellID", for: indexPath)
        if let cell = cell as? SuggestionTableViewCell {
            cell.suggestionTextLabel.text = suggestedSearch[indexPath.item]
        }
        return cell
    }
    
    @IBOutlet weak var searchBarView: UISearchBar!
    @IBOutlet weak var suggestionTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    var searchString = ""
    var lastFrame = CGRect()
    var currentSearchBarText: String? {
        return searchBarView.text
    }
    var suggestedSearch = [String]() {
        didSet {
            suggestionTableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBarView.becomeFirstResponder()
        searchBarView.delegate = self
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.isFirstResponder {
            fetchSuggestionForSearch(searchText)
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchString = searchBar.text ?? ""
        performSegue(withIdentifier: "SearchResultsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchString = suggestedSearch[indexPath.item]
        performSegue(withIdentifier: "SearchResultsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? SearchResultViewController{
            des.searchString = searchString
            des.searchText = searchString
            searchBarView.text = searchString
        }
    }
    
    func fetchSuggestionForSearch( _ text: String) {
        if let url = URL(string: "http://suggestqueries.google.com/complete/search?hl=en&ds=yt&client=youtube&hjson=t&cp=1&q=\(text.replacingOccurrences(of: " ", with: "%20"))&format=5&alt=json") {
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                
                do {
                    var strings = [String]()
                    if let firstArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                        firstArray.forEach { firstElement in
                            if let second = firstElement as? [Any] {
                                second.forEach { secElement in
                                    if let last = secElement as? [Any] {
                                        if let string = last.first as? String {
                                            strings.append(string)
                                        }
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.suggestedSearch = strings
                        }
                        
                    }
                    
                } catch  {
                    print(error.localizedDescription)
                }
            }.resume()
        }
        
    }
}

extension SearchViewController: TransitionInfoProtocol {
    func viewsToAnimate() -> [UIView] {
        return [backButton, searchBarView]
    }
    
    func copyForView(_ subView: UIView, index: Int) -> UIView {
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
    }
    
    
}

//        if let frame = navigationController?.navigationBar.frame {
//            let vv = UIView()
//            vv.backgroundColor = .clear
//            vv.frame = .init(x: 0, y: 0, width: frame.width, height: frame.height)
//            vv.clipsToBounds = true
//            navigationItem.titleView = vv
//
//        }

//        if let view =  navigationItem.titleView {
//            let frame = view.frame
//            let searchBar = UISearchBar(frame: CGRect(origin: .zero, size: CGSize(width: frame.width , height: frame.height - 5)))
//            view.addSubview(searchBar)
//            searchBar.clipsToBounds = true
//
//
//        }
