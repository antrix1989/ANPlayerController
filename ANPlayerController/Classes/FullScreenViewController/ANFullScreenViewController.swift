//
//  ANFullScreenViewController.swift
//  Pods
//
//  Created by Sergey Demchenko on 6/30/16.
//
//

import UIKit

class ANFullScreenViewController: UIViewController
{
    @IBOutlet var fullScreenView: ANFullScreenView!
    var player: ANPlayerController?
    
    init()
    {
        super.init(nibName: "ANFullScreenViewController", bundle: NSBundle(forClass: self.dynamicType))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // MARK: - IBAction
    
    @IBAction func onCloseNotificationButtonTapped(sender: AnyObject)
    {
        player?.stop()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
