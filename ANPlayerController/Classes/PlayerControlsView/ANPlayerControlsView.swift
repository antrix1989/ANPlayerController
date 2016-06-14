//
//  ANPlayerControlsView.swift
//  Pods
//
//  Created by Sergey Demchenko on 6/15/16.
//
//

import UIKit

public class ANPlayerControlsView: UIView
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
}
