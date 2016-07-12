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
    lazy var vodItems: [VODItem] = ({
        var vodItems = [VODItem]()
        
        for i in 0...10 {
            let voidItem = VODItem()
            voidItem.videoUrl = NSURL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu")
            voidItem.videoThumbnailUrl = NSURL(string: "https://cdn.filestackcontent.com/3p5lj8hdQMW1T6eZHtji")
            
            vodItems.append(voidItem)
        }
        
        return vodItems
    })()
    
    var player = ANPlayerController()
    var currentPlayingIndexPath: NSIndexPath?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        player.controlsView = ANPlayerControlsView.createFromNib()
        
        player.onViewTappedBlock = { [weak self] () -> Void in
            if let weakSelf = self where !weakSelf.player.isFullScreen {
                weakSelf.player.setFullscreen(true, animated: true)
                weakSelf.player.mute(false)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return vodItems.count }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
        let vodItem = vodItems[indexPath.row]
        
        cell.videoThumbnailImageView.sd_setImageWithURL(vodItem.videoThumbnailUrl)
        
        cell.onPlayButtonTappedBlock = { [weak self] (sender) -> Void in
            self?.playVideoAtIndexPath(indexPath)
            self?.player.setFullscreen(true, animated: true)
            self?.player.mute(false)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if let currentPlayingIndexPath = self.currentPlayingIndexPath where currentPlayingIndexPath == indexPath {
            player.stop()
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
    
    private func playVideoAtIndexPath(indexPath: NSIndexPath)
    {
        if let currentPlayingIndexPath = currentPlayingIndexPath where indexPath == currentPlayingIndexPath { return }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! VideoTableViewCell
        cell.showLoadingAnimation(true)
        
        player.onReadyToPlayBlock = { () -> Void in
            cell.showVideoView(true)
            cell.showLoadingAnimation(false)
        }
        
        player.stop()
        player.view.removeFromSuperview()
        cell.videoContainerView.addSubview(player.view)
        player.view.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(cell.videoContainerView.snp_top)
            make.bottom.equalTo(cell.videoContainerView.snp_bottom)
            make.left.equalTo(cell.videoContainerView.snp_left)
            make.right.equalTo(cell.videoContainerView.snp_right)
        }
        
        let vodItem = vodItems[indexPath.row]
        
        currentPlayingIndexPath = indexPath
        
        player.playable = vodItem
        player.prepare()
        player.mute(true)
        player.play()
        
        player.onPlayableDidFinishPlayingBlock = { [weak self] (playable) -> Void in
            if let weakSelf = self, let cell = weakSelf.tableView.cellForRowAtIndexPath(indexPath) as? VideoTableViewCell {
                cell.showVideoView(false)
                weakSelf.player.view.removeFromSuperview()
                weakSelf.currentPlayingIndexPath = nil
            }
        }
    }
    
    private func stopVideoPlayingAtIndexPath(indexPath: NSIndexPath)
    {
        if let currentPlayingIndexPath = self.currentPlayingIndexPath where currentPlayingIndexPath == indexPath {
            player.stop()
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! VideoTableViewCell
        cell.showVideoView(false)
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
