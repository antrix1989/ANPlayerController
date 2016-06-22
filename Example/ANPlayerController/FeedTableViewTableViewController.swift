//
//  FeedTableViewTableViewController.swift
//  ANPlayerController
//
//  Created by Sergey Demchenko on 6/16/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ANPlayerController
import SnapKit

class FeedTableViewTableViewController: UITableViewController
{
    let videoUrls = [
        NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1"),
        NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1"),
        NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1"),
        NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1"),
        NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1"),
        NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1"),
        NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1"),
        NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1")
    ]
    
    var player = ANPlayerController()
    var currentPlayingIndexPath: NSIndexPath?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        player.controlsView = ANPlayerControlsView.createFromNib()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return videoUrls.count }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
//        let videoUrl = videoUrls[indexPath.row]
//
//        let vodItem = VODItem()
//        vodItem.contentVideoUrl = videoUrl
//        
//        player.view.removeFromSuperview()
//        cell.videoContainerView.addSubview(player.view)
//        player.view.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(cell.videoContainerView.snp_top)
//            make.bottom.equalTo(cell.videoContainerView.snp_bottom)
//            make.left.equalTo(cell.videoContainerView.snp_left)
//            make.right.equalTo(cell.videoContainerView.snp_right)
//        }
//        
//        player.playable = vodItem
   
        return cell
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        player.stop()
        player.view.removeFromSuperview()
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        onScrollViewEndScrolling()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !decelerate { onScrollViewEndScrolling() }
    }
    
    // MARK: - Private
    
    private func playVideoAtIndexPath(indexPath: NSIndexPath)
    {
        if let currentPlayingIndexPath = currentPlayingIndexPath where indexPath == currentPlayingIndexPath { return }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! VideoTableViewCell
        
        player.view.removeFromSuperview()
        cell.videoContainerView.addSubview(player.view)
        player.view.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(cell.videoContainerView.snp_top)
            make.bottom.equalTo(cell.videoContainerView.snp_bottom)
            make.left.equalTo(cell.videoContainerView.snp_left)
            make.right.equalTo(cell.videoContainerView.snp_right)
        }
        
        let videoUrl = videoUrls[indexPath.row]
        let vodItem = VODItem()
        vodItem.contentVideoUrl = videoUrl
        
        currentPlayingIndexPath = indexPath
        
        player.playable = vodItem
        player.prepare()
        player.play()
    }
    
    private func stopVideoPlayingAtIndexPath(indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! VideoTableViewCell
        if cell.videoContainerView.subviews.contains(player.view) {
            player.view.removeFromSuperview()
        }
    }
    
    private func onScrollViewEndScrolling()
    {
        var isPlayingCellFound = false
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPathForCell(cell) {
                if isPlayingCellFound {
                    stopVideoPlayingAtIndexPath(indexPath)
                    continue
                }
                
                let rectInTableView = tableView.rectForRowAtIndexPath(indexPath)
                let rectInSuperview = tableView.convertRect(rectInTableView, toView: tableView.superview)
                
                let intersection = CGRectIntersection(tableView.frame, rectInSuperview)
                let visibleHeight = CGRectGetHeight(intersection)
                let cellHeigt = CGRectGetHeight(rectInTableView)
                let navigationBarHeight = navigationController?.navigationBar.bounds.height ?? 0
                if visibleHeight - navigationBarHeight > cellHeigt * 0.6 {
                    isPlayingCellFound = true
                    playVideoAtIndexPath(indexPath)
                } else {
                    stopVideoPlayingAtIndexPath(indexPath)
                }
            }
        }
    }
}
