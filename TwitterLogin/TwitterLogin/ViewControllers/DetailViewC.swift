//
//  DetailViewC.swift
//  TwitterLogin
//
//  Created by Admin on 10/03/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import TwitterKit

class DetailViewC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var txtHandleName: UITextField!
    @IBOutlet weak var btnFetxhDetails: UIButton!
    @IBOutlet weak var lblTweets: UILabel!
    @IBOutlet weak var lblHashTags: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    
    // MARK: - Properties
    private var tweets = [TWTRTweet]()
    private var tagList = Set<String>()
    private var followers = [TWTRUser]()
    private var isFollowersFetched: Bool = false
    private var isTweetsTagsFetched: Bool = false
    
    // MARK:- Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapFetchDetails(_ sender: UIButton) {
        guard let handleName = self.txtHandleName.text else { return }
        if handleName.isEmpty {
            self.showAlertWith(message: "Handlename can't be empty.")
            return
        }
        self.clearPreviousData()
        ANLoader.showLoading()
        self.getFollowersList(twitterHandler: handleName)
        self.fetchAllTweets(twitterHandler: handleName)
    }
    
    
    // MARK: - Private Methods
    private func getFollowersList(twitterHandler: String) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let url = "https://api.twitter.com/1.1/followers/list.json?"
            let params = ["screen_name": twitterHandler]
            var clientError : NSError?
            let clients = TWTRAPIClient.withCurrentUser()
            let request = clients.urlRequest(withMethod: "GET", urlString: url, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { [weak self] (response, data, connectionError) -> Void in
                guard let self = self else { return }
                if connectionError !=  nil && self.isFollowersFetched == false {
                    self.isTweetsTagsFetched = true
                    self.isFollowersFetched = true
                    self.checkForFetchProgress()
                    self.showAlertWith(message: connectionError!.localizedDescription)
                    return
                }
                if let someData = data {
                    do {
                        let results = try JSONSerialization.jsonObject(with: someData, options: .allowFragments) as! NSDictionary
                        self.lblFollowers.text = "Number of followers gained recently: \(results.count)"
                    } catch {
                    }
                }
                self.isFollowersFetched = true
                self.checkForFetchProgress()
            }
        }
    }
    
    private func fetchAllTweets(twitterHandler: String) {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let datasource = TWTRUserTimelineDataSource(screenName: twitterHandler, apiClient: client)
            datasource.loadPreviousTweets(beforePosition: nil) { [weak self] (tweets, timeLineCursor, error) in
                guard let self = self else { return }
                if error !=  nil && self.isTweetsTagsFetched == false {
                    self.isTweetsTagsFetched = true
                    self.isFollowersFetched = true
                    self.checkForFetchProgress()
                    self.showAlertWith(message: error!.localizedDescription)
                    return
                }
                guard let safeTweets = tweets else { return }
                for tweet in safeTweets {
                    if Date().daysFrom(tweet.createdAt) <= 7 {
                        self.addTweetInfo(tweet: tweet)
                    }
                }
                self.lblHashTags.text = "Number of hash tags used in last 1 week: \(self.tagList.count)"
                self.lblTweets.text = "Number of tweets in last 1 week: \(self.tweets.count)"
                self.isTweetsTagsFetched = true
                self.checkForFetchProgress()
            }
        }
    }
    
    private func addTweetInfo(tweet: TWTRTweet) {
        let components = tweet.text.components(separatedBy: [" "])
        let tags = components.filter { (word) -> Bool in
            return word.hasPrefix("#")
        }
        self.tagList.formUnion(tags)
        self.tweets.append(tweet)
        self.lblHashTags.text = "Number of hash tags used in last 1 week: nil"
        self.lblTweets.text = "Number of tweets in last 1 week: nil"
        self.lblFollowers.text = "Number of followers gained recently: nil"
    }

    private func clearPreviousData() {
        self.isFollowersFetched = false
        self.isTweetsTagsFetched = false
        self.tagList.removeAll()
        self.tweets.removeAll()
        self.followers.removeAll()
    }
    
    private func checkForFetchProgress() {
        if self.isTweetsTagsFetched && self.isFollowersFetched {
            ANLoader.hide()
        }
    }
    
    private func showAlertWith(message: String) {
        let alertController = UIAlertController(title: nil, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
}
