//
//  TimelineViewController.swift
//  twitter_sample
//
//  Created by NAGAMINE HIROMASA on 2015/08/16.
//  Copyright (c) 2015年 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Social
import Accounts

class TimelineViewController: UITableViewController{

    let cellIdentifier = "tweetCell"
    var tweets = []
    
    var twAccount = ACAccount()

    // タイムライン画面のローディング(ライフサイクルメソッド)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "TL"
        fetchTimeline()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.contentOffset.y = -self.refreshControl!.frame.size.height
        
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine

    }

    // メモリーが不足した時にOSから呼ばれる(ライフサイクルメソッド)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - Table view data source
    // テーブルが持つsectionの数を指定(UITableView ライフサイクルメソッド)
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Sectionは１つにする
        return 1
    }

    // テーブルがsectionごとに持つセルの数を指定(UITableView ライフサイクルメソッド)
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    // 各セルをsection, rowごとに初期化(UITableView ライフサイクルメソッド)
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // TableViewの使っていないセルを再利用
        var cell = tableView.dequeueReusableCellWithIdentifier("tweetCell")

        // 再利用できるセルがなければ初期化
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }

        // セルに表示するサムネ・ツイート・名前の設定
        let tweet = tweets[indexPath.row] as! Dictionary<String,AnyObject>
        let text = tweet["text"] as! String
        let user = tweet["user"] as! Dictionary<String,AnyObject>
        let name = user["name"] as! String
       
        let image = UIImage(data: NSData(contentsOfURL: NSURL(string: user["profile_image_url_https"] as! String)!)!)!
        
        let aCell = cell!
        aCell.imageView?.image = image
        aCell.textLabel?.text = text
        aCell.detailTextLabel?.text = name
        
        return aCell
    }

    // 各セルの高さをsection, rowごとに指定(UITableView ライフサイクルメソッド)
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 50.0
//    }

    // セルをタップした時に呼ばれる(UITableView ユーザーアクションメソッド)
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showTimelineDetailViewController", sender: nil)
    }
    
    //  Twitter APIを使ってタイムラインを取得しtweetsに保存する
    func fetchTimeline() {
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: URL, parameters: nil)
        request.account = twAccount
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        request.account = twAccount
        request.performRequestWithHandler { (data, response, error:NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                print("Fetching Error: \(error)")
                return
            }else{
            
                do{
                    self.tweets = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSArray
                }catch{
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    func refresh(){
        fetchTimeline()
        self.refreshControl?.endRefreshing()
    }
}
