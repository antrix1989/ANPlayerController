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
import SDWebImage

class FeedTableViewTableViewController: UITableViewController
{
    let videoUrls = [
        NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu"),
        NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu"),
        NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu"),
        NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu"),
        NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu"),
        NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu"),
        NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu"),
        NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu")
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
        return cell
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if let currentPlayingIndexPath = self.currentPlayingIndexPath where currentPlayingIndexPath == indexPath {
            stopPlayer()
        }
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
    
    func stopPlayer()
    {
        player.stop()
        player.view.removeFromSuperview()
        currentPlayingIndexPath = nil
    }
    
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
        if let currentPlayingIndexPath = self.currentPlayingIndexPath where currentPlayingIndexPath == indexPath {
            stopPlayer()
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
