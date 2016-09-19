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
    case pause
    case play
}

open class ANPlayerControlsView: UIView, UIGestureRecognizerDelegate
{
    @IBOutlet weak open var playButton: UIButton?
    @IBOutlet weak open var pauseButton: UIButton?
    @IBOutlet weak open var stopButton: UIButton?
    @IBOutlet weak open var backButton: UIButton?
    @IBOutlet weak open var forwardButton: UIButton?
    @IBOutlet weak open var seekSlider: UISlider?
    @IBOutlet weak open var currentTimeLabel: UILabel?
    @IBOutlet weak open var totalTimeLabel: UILabel?
    @IBOutlet weak open var controlsView: UIView?
    
    var state: ANPlayerControlsViewState = .pause {
        didSet {
            switch state {
            case .play:
                pauseButton?.isHidden = false
                playButton?.isHidden = true
            default:
                pauseButton?.isHidden = true
                playButton?.isHidden = false
            }
        }
    }
    
    open override func awakeFromNib()
    {
        super.awakeFromNib()
        
        state = .pause
        
        let minTrackImage = UIImage(named: "min_slide_track", in: Bundle(for: type(of: self)), compatibleWith: nil)?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 0)
        let maxTrackImage = UIImage(named: "max_slide_track", in: Bundle(for: type(of: self)), compatibleWith: nil)?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 0)
        
        seekSlider?.setThumbImage(UIImage(named: "slide_thumb", in: Bundle(for: type(of: self)), compatibleWith: nil), for: UIControlState())
        seekSlider?.setMinimumTrackImage(minTrackImage, for: UIControlState())
        seekSlider?.setMaximumTrackImage(maxTrackImage, for: UIControlState())
    }
}
