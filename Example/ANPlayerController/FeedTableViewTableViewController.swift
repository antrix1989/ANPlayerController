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
            voidItem.videoUrl = URL(string: "https://cdn.filestackcontent.com/ocLFkfTtRgq3p5QG0unu")
            voidItem.videoThumbnailUrl = URL(string: "https://cdn.filestackcontent.com/3p5lj8hdQMW1T6eZHtji")
            
            vodItems.append(voidItem)
        }
        
        return vodItems
    })()
    
    var player = ANPlayerController()
    var currentPlayingIndexPath: IndexPath?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        player.controlsView = ANPlayerControlsView.createFromNib()
        
        player.onViewTappedBlock = { [weak self] () -> Void in
            if let weakSelf = self , !weakSelf.player.isFullScreen {
                weakSelf.player.setFullscreen(true, animated: true)
                weakSelf.player.mute(false)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return vodItems.count }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath) as! VideoTableViewCell
        let vodItem = vodItems[(indexPath as NSIndexPath).row]
        
        cell.videoThumbnailImageView.sd_setImage(with: vodItem.videoThumbnailUrl as URL!)
        
        cell.onPlayButtonTappedBlock = { [weak self] (sender) -> Void in
            self?.playVideoAtIndexPath(indexPath)
            self?.player.setFullscreen(true, animated: true)
            self?.player.mute(false)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if let currentPlayingIndexPath = self.currentPlayingIndexPath , currentPlayingIndexPath == indexPath {
            player.stop()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        onScrollViewEndScrolling()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !decelerate { onScrollViewEndScrolling() }
    }
    
    // MARK: - Private
    
    fileprivate func playVideoAtIndexPath(_ indexPath: IndexPath)
    {
        if let currentPlayingIndexPath = currentPlayingIndexPath , indexPath == currentPlayingIndexPath { return }
        
        let cell = tableView.cellForRow(at: indexPath) as! VideoTableViewCell
        cell.showLoadingAnimation(true)
        
        player.onReadyToPlayBlock = { () -> Void in
            cell.showVideoView(true)
            cell.showLoadingAnimation(false)
        }
        
        player.stop()
        player.view.removeFromSuperview()
        cell.videoContainerView.addSubview(player.view)
        player.view.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(cell.videoContainerView.snp.top)
            make.bottom.equalTo(cell.videoContainerView.snp.bottom)
            make.left.equalTo(cell.videoContainerView.snp.left)
            make.right.equalTo(cell.videoContainerView.snp.right)
        }
        
        let vodItem = vodItems[(indexPath as NSIndexPath).row]
        
        currentPlayingIndexPath = indexPath
        
        player.playable = vodItem
        player.prepare()
        player.mute(true)
        player.play()
        
        player.onPlayableDidFinishPlayingBlock = { [weak self] (playable) -> Void in
            if let weakSelf = self, let cell = weakSelf.tableView.cellForRow(at: indexPath) as? VideoTableViewCell {
                cell.showVideoView(false)
                weakSelf.player.view.removeFromSuperview()
                weakSelf.currentPlayingIndexPath = nil
            }
        }
    }
    
    fileprivate func stopVideoPlayingAtIndexPath(_ indexPath: IndexPath)
    {
        if let currentPlayingIndexPath = self.currentPlayingIndexPath , currentPlayingIndexPath == indexPath {
            player.stop()
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! VideoTableViewCell
        cell.showVideoView(false)
    }
    
    fileprivate func onScrollViewEndScrolling()
    {
        var isPlayingCellFound = false
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                if isPlayingCellFound {
                    stopVideoPlayingAtIndexPath(indexPath)
                    continue
                }
                
                let rectInTableView = tableView.rectForRow(at: indexPath)
                let rectInSuperview = tableView.convert(rectInTableView, to: tableView.superview)
                
                let intersection = tableView.frame.intersection(rectInSuperview)
                let visibleHeight = intersection.height
                let cellHeigt = rectInTableView.height
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
