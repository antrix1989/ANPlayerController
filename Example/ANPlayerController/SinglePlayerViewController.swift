//
//  SinglePlayerViewController.swift
//  ANPlayerController
//
//  Created by Sergey Demchenko on 06/14/2016.
//  Copyright (c) 2016 Sergey Demchenko. All rights reserved.
//

import UIKit
import ANPlayerController
import SnapKit

class SinglePlayerViewController: UIViewController
{
    @IBOutlet var containerView: UIView!
    
    let player = ANPlayerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        let vodItem = VODItem()
        vodItem.contentVideoUrl = NSURL(string: "https://www.dropbox.com/s/db5rqi1vjw7edlr/%D0%A3%D0%B6%D0%B0%D1%81%D1%8B%20%C2%AB%D0%A2%D0%B5%D0%BB%D0%B5%D0%BA%D0%B8%D0%BD%D0%B5%D0%B7%C2%BB%20%28%D1%80%D0%B5%D0%BC%D0%B5%D0%B9%D0%BA%20%D0%9A%D1%8D%D1%80%D1%80%D0%B8%20%D1%81%20%D0%A5%D0%BB%D0%BE%D0%B5%D0%B9%20%D0%9C%D0%BE%D1%80%D0%B5%D1%86%29%20%D0%9E%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9%20%D0%B4%D1%83%D0%B1%D0%BB%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%BD%D1%8B%D0%B9%20%D0%A2%D1%80%D0%B5%D0%B9%D0%BB%D0%B5%D1%80%20%D1%84%D0%B8%D0%BB%D1%8C%D0%BC%D0%B0.mp4?dl=1")

        player.controlsView = ANPlayerControlsView.createFromNib()
        player.playable = vodItem
        player.prepare()
        
        containerView.addSubview(player.view)
        player.view.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(containerView.snp_top)
            make.bottom.equalTo(containerView.snp_bottom)
            make.left.equalTo(containerView.snp_left)
            make.right.equalTo(containerView.snp_right)
        }
        player.view.frame = containerView.bounds
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        player.play()
    }
}