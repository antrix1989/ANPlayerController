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
    
    var onCloseButtonTapped : (() -> Void) = { () -> Void in }
    
    init()
    {
        super.init(nibName: "ANFullScreenViewController", bundle: NSBundle(forClass: self.dynamicType))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func prefersStatusBarHidden() -> Bool { return true }
    
    // MARK: - IBAction
    
    @IBAction func onCloseButtonTapped(sender: AnyObject)
    {
        onCloseButtonTapped()
    }
}
