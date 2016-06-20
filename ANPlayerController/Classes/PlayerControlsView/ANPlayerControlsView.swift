//
//  ANPlayerControlsView.swift
//  Pods
//
//  Created by Sergey Demchenko on 6/15/16.
//
//

import UIKit

enum ANPlayerControlsViewState
{
    case Pause
    case Play
}

public class ANPlayerControlsView: UIView, UIGestureRecognizerDelegate
{
    @IBOutlet weak public var playButton: UIButton?
    @IBOutlet weak public var pauseButton: UIButton?
    @IBOutlet weak public var stopButton: UIButton?
    @IBOutlet weak public var backButton: UIButton?
    @IBOutlet weak public var forwardButton: UIButton?
    @IBOutlet weak public var seekSlider: UISlider?
    @IBOutlet weak public var currentTimeLabel: UILabel?
    @IBOutlet weak public var totalTimeLabel: UILabel?
    @IBOutlet weak public var controlsView: UIView?
    
    var state: ANPlayerControlsViewState = .Pause {
        didSet {
            switch state {
            case .Play:
                pauseButton?.hidden = false
                playButton?.hidden = true
            default:
                pauseButton?.hidden = true
                playButton?.hidden = false
            }
        }
    }
    
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        
        state = .Pause
        
        let minTrackImage = UIImage(named: "min_slide_track", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)?.stretchableImageWithLeftCapWidth(10, topCapHeight: 0)
        let maxTrackImage = UIImage(named: "max_slide_track", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)?.stretchableImageWithLeftCapWidth(10, topCapHeight: 0)
        
        seekSlider?.setThumbImage(UIImage(named: "slide_thumb", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil), forState: .Normal)
        seekSlider?.setMinimumTrackImage(minTrackImage, forState: .Normal)
        seekSlider?.setMaximumTrackImage(maxTrackImage, forState: .Normal)
    }
}
