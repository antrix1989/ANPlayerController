//
//  ANPlayerController.swift
//  Pods
//
//  Created by Sergey Demchenko on 6/14/16.
//
//

import UIKit
import AVFoundation
import SnapKit

public class ANPlayerController: NSObject, UIGestureRecognizerDelegate, ANMediaPlayback
{
    public var playable: ANPlayable?
    
    /// The player view.
    public lazy var view: UIView = ({
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 160))
        view.backgroundColor = UIColor.blackColor()
        if let activityIndicatorView = self.activityIndicatorView {
            activityIndicatorView.hidesWhenStopped = true
            view.addSubview(activityIndicatorView)
            activityIndicatorView.snp_makeConstraints { (make) -> Void in
                make.center.equalTo(view.snp_center)
            }
        }
        
        view.addObserver(self, forKeyPath: "bounds", options: [], context: &self.playerKVOContext)
        
        return view
    })()
    
    /// A view that confiorms to the <code>ANPlayerControls</code> protocol.
    public var controlsView: ANPlayerControlsView?
    
    /// Hide controls after interval.
    public var hidingControlsInterval: NSTimeInterval = 3
    
    /// Video loading indciator view.
    public var activityIndicatorView: UIActivityIndicatorView?
    
    public var onPlayableDidFinishPlayingBlock : ((ANPlayable?) -> Void) = { (playable) -> Void in }
    public var onReadyToPlayBlock : (() -> Void) = { () -> Void in }
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var hideControlsTimer: NSTimer?
    var restoreAfterScrubbingRate: Float = 0
    var playbackTimeObserver: AnyObject?
    var tapRecognizer: UITapGestureRecognizer?
    
    private var playerKVOContext = 0
    
    public override init()
    {
        super.init()
    }
    
    deinit
    {
        view.removeObserver(self, forKeyPath: "bounds")
        
        removePlayer()
    }
    
    // MARK: - Public
    
    public func prepare()
    {
        removePlayer()
        resetControlsView()
        
        if let contentVideoUrl = playable?.contentVideoUrl  {
            createPlayer(contentVideoUrl)
        }
        
        if let controlsView = controlsView {
            controlsView.frame = view.bounds
            view.addSubview(controlsView)
            controlsView.snp_makeConstraints { (make) -> Void in
                make.top.equalTo(view.snp_top)
                make.bottom.equalTo(view.snp_bottom)
                make.left.equalTo(view.snp_left)
                make.right.equalTo(view.snp_right)
            }
            
            controlsView.state = .Pause
            controlsView.hidden = true
            
            controlsView.playButton?.addTarget(self, action: #selector(onPlayButtonTapped(_:)), forControlEvents: .TouchUpInside)
            controlsView.pauseButton?.addTarget(self, action: #selector(onPauseButtonTapped(_:)), forControlEvents: .TouchUpInside)
            controlsView.seekSlider?.addTarget(self, action: #selector(onScrub(_:)), forControlEvents: .ValueChanged)
            controlsView.seekSlider?.addTarget(self, action: #selector(onBeginScrubbing(_:)), forControlEvents: .TouchDown)
            controlsView.seekSlider?.addTarget(self, action: #selector(onEndScrubbing(_:)), forControlEvents: .TouchUpInside)
            controlsView.seekSlider?.addTarget(self, action: #selector(onEndScrubbing(_:)), forControlEvents: .TouchUpOutside)
        }
        
        addTapGestureRecognizer()
    }
//    
//    public func setFullscreen(fullscreen: Bool, animated: Bool)
//    {
//        let superView = view.superview
//        
//        view.removeFromSuperview()
////        UIScreen.mainScreen().view
//        UIApplication.sharedApplication().keyWindow?.addSubview(view)
//    }
    
    // MARK: - ANMediaPlayback
    
    public func play()
    {
        controlsView?.state = .Play
        
        activityIndicatorView?.startAnimating()
        addPlaybackTimeObserver()
        player?.play()
    }
    
    public func pause()
    {
        stopHideControllsTimer()
        
        controlsView?.state = .Pause
        controlsView?.hidden = false
        
        player?.pause()
    }
    
    public func stop()
    {
        player?.pause()
        seekToTime(0)
        resetControlsView()
        
        onPlayableDidFinishPlayingBlock(playable)
    }
    
    public func seekToTime(time: NSTimeInterval)
    {
        player?.seekToTime(CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)))
    }
    
    // MARK: - KVO
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if context != &playerKVOContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if let player = object as? AVPlayer where player == self.player && keyPath == "status" {
            activityIndicatorView?.stopAnimating()
            
            if player.status == .Failed {
                debugPrint(player.error)
            } else if player.status == .ReadyToPlay {
                onReadyToPlayBlock()
            }
            
            updateControlsView()
        } else if keyPath == "bounds" {
            playerLayer?.frame = view.bounds
        }
    }
    
    // MARK: - Protected
    
    func onItemDidFinishPlayingNotification(notification: NSNotification)
    {
        stop()
    }
    
    func createPlayer(contentVideoUrl: NSURL)
    {
        let playerItem = AVPlayerItem(URL: contentVideoUrl)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onItemDidFinishPlayingNotification(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        player = AVPlayer(playerItem: playerItem)
        player!.addObserver(self, forKeyPath: "status", options: [], context: &playerKVOContext)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer?.frame = view.bounds
        
        view.layer.addSublayer(playerLayer!)
    }
    
    func removePlayer()
    {
        if let playerItem = player?.currentItem {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        }
        
        player?.removeObserver(self, forKeyPath: "status")
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        removePlaybackTimeObserver()
    }
    
    func minutes(totalSeconds: Double) -> Int { return Int(floor(totalSeconds % 3600 / 60)) }
    
    func seconds(totalSeconds: Double) -> Int { return Int(floor(totalSeconds % 3600 % 60)) }
    
    func resetControlsView()
    {
        setCurrentTimeLabelValue(kCMTimeZero)
        controlsView?.state = .Pause
        controlsView?.seekSlider?.minimumValue = 0
        controlsView?.seekSlider?.maximumValue = 0
        controlsView?.seekSlider?.value = 0
        
        updateControlsView()
    }
    
    func updateControlsView()
    {
        if let duration = player?.currentItem?.asset.duration {
            let durationTotalSeconds = CMTimeGetSeconds(duration)
            
            controlsView?.totalTimeLabel?.text = String(format: "%02lu:%02lu", minutes(durationTotalSeconds), seconds(durationTotalSeconds))
            controlsView?.seekSlider?.maximumValue = Float(durationTotalSeconds)
        }
    }
    
    func stopHideControllsTimer()
    {
        hideControlsTimer?.invalidate()
        hideControlsTimer = nil
    }
    
    func removePlaybackTimeObserver()
    {
        if let playbackTimeObserver = playbackTimeObserver {
            player?.removeTimeObserver(playbackTimeObserver)
            self.playbackTimeObserver = nil
        }
    }
    
    func setCurrentTimeLabelValue(time: CMTime)
    {
        let currentTimeTotalSeconds = CMTimeGetSeconds(time)
        
        controlsView?.currentTimeLabel?.text = String(format: "%02lu:%02lu", minutes(currentTimeTotalSeconds), seconds(currentTimeTotalSeconds))
    }
    
    func addPlaybackTimeObserver()
    {
        if let _ = playbackTimeObserver { return }
        
        let interval = CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC)) // 1 second
        playbackTimeObserver = player?.addPeriodicTimeObserverForInterval(interval, queue: nil, usingBlock: { [weak self] (time) in
            if let rate = self?.player?.rate where rate == 0 { return }
            
            self?.setCurrentTimeLabelValue(time)
            
            let currentTimeTotalSeconds = CMTimeGetSeconds(time)
            self?.controlsView?.seekSlider?.value = Float(currentTimeTotalSeconds)
            
            if let weakSelf = self, let controlsView = weakSelf.controlsView
                where weakSelf.hideControlsTimer == nil && !controlsView.hidden {
                self?.hideControlsView(true, afterInterval: weakSelf.hidingControlsInterval)
            }
        })
    }
    
    func hideControlsView(hide: Bool, afterInterval interval: NSTimeInterval)
    {
        hideControlsTimer = NSTimer.schedule(delay: interval) { [weak self] (timer) in
            self?.controlsView?.hidden = hide
            self?.hideControlsTimer?.invalidate()
            self?.hideControlsTimer = nil
        }
    }
    
    // MARK: - UITapGestureRecognizer
    
    func removeTapGestureRecognizer()
    {
        if let tapRecognizer = self.tapRecognizer {
            view.removeGestureRecognizer(tapRecognizer)
            self.tapRecognizer = nil
        }
    }
    
    func addTapGestureRecognizer()
    {
        removeTapGestureRecognizer()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(_:)))
        tapRecognizer?.cancelsTouchesInView = false
        tapRecognizer?.delegate = self
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func onTapGesture(recognizer: UITapGestureRecognizer)
    {
        controlsView?.hidden = false
        stopHideControllsTimer()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        return view == touch.view
    }
    
    // MARK: - IBAction
    
    @IBAction func onPlayButtonTapped(sender: AnyObject)
    {
        play()
    }
    
    @IBAction func onPauseButtonTapped(sender: AnyObject)
    {
        pause()
    }
    
    /// User is dragging the movie controller thumb to scrub through the movie.
    
    @IBAction func onBeginScrubbing(slider: UISlider)
    {
        stopHideControllsTimer()
        
        if let player = player {
            restoreAfterScrubbingRate = player.rate
            player.rate = 0
        }
        
        removePlaybackTimeObserver()
    }
    
    @IBAction func onScrub(slider: UISlider)
    {
        if let playerDuration = player?.currentItem?.asset.duration where CMTIME_IS_INVALID(playerDuration) { return }
        
        if let timeScale = player?.currentItem?.asset.duration.timescale {
            let time = CMTimeMakeWithSeconds(Float64(slider.value), timeScale)
            player?.seekToTime(time)
            setCurrentTimeLabelValue(time)
        }
    }
    
    @IBAction func onEndScrubbing(slider: UISlider)
    {
        if restoreAfterScrubbingRate != 0 {
            player?.rate = restoreAfterScrubbingRate
            restoreAfterScrubbingRate = 0
        }
        
        addPlaybackTimeObserver()
        hideControlsView(true, afterInterval: hidingControlsInterval)
    }
}
