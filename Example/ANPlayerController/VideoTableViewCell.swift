//
//  VideoTableViewCell.swift
//  ANPlayerController
//
//  Created by Sergey Demchenko on 6/16/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell
{
    @IBOutlet var videoContainerView: UIView!
    @IBOutlet var videoThumnailContainerView: UIView!
    @IBOutlet var videoThumbnailImageView: UIImageView!
    
    var onPlayButtonTappedBlock : ((AnyObject) -> Void) = { (sender) -> Void in }
    
    func showVideoView(show: Bool)
    {
        videoContainerView.hidden = !show
        videoThumnailContainerView.hidden = !videoContainerView.hidden
    }
    
    // MARK: - IBAction
    
    @IBAction func onPlayButtonTapped(sender: AnyObject)
    {
        onPlayButtonTappedBlock(sender)
    }
}
