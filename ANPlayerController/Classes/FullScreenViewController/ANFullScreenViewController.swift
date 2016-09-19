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
        super.init(nibName: "ANFullScreenViewController", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override var prefersStatusBarHidden : Bool { return true }
    
    // MARK: - IBAction
    
    @IBAction func onCloseButtonTapped(_ sender: AnyObject)
    {
        onCloseButtonTapped()
    }
}
