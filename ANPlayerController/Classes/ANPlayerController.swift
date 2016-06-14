//
//  ANPlayerController.swift
//  Pods
//
//  Created by Sergey Demchenko on 6/14/16.
//
//

import UIKit
import AVFoundation

public class ANPlayerController: NSObject, UIGestureRecognizerDelegate, ANMediaPlayback
{
    public var playable: ANPlayable?
    
    /// The player view.
    public lazy var view: UIView = ({
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 160))
        view.backgroundColor = UIColor.blackColor()
        self.activityIndicatorView.center = view.center
        self.activityIndicatorView.hidesWhenStopped = true
        view.addSubview(self.activityIndicatorView)
        
        view.addObserver(self, forKeyPath: "frame", options: [], context: &self.playerKVOContext)
        
        return view
    })()
    
    /// A view that confiorms to the <code>ANPlayerControls</code> protocol.
    public var controlsView: ANPlayerControlsView?
    
    /// Hide controls after interval.
    public var hidingControlsInterval: NSTimeInterval = 3
    
    /// Video loading indciator view.
    public var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
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
        removePlaybackTimeObserver()
    }
    
    // MARK: - Public
    
    public func prepare()
    {
        if let contentVideoUrl = playable?.contentVideoUrl  {
            player = AVPlayer(URL: contentVideoUrl)
            player!.addObserver(self, forKeyPath: "status", options: [], context: &playerKVOContext)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            view.layer.addSublayer(playerLayer!)
        }
        
        if let controlsView = controlsView {
            controlsView.frame = view.bounds
            view.addSubview(controlsView)
            
            controlsView.pauseButton?.hidden = true
            controlsView.seekSlider?.minimumValue = 0
            controlsView.seekSlider?.maximumValue = 0
            controlsView.seekSlider?.value = 0
            
            controlsView.playButton?.addTarget(self, action: #selector(onPlayButtonTapped(_:)), forControlEvents: .TouchUpInside)
            controlsView.pauseButton?.addTarget(self, action: #selector(onPauseButtonTapped(_:)), forControlEvents: .TouchUpInside)
            controlsView.seekSlider?.addTarget(self, action: #selector(onScrub(_:)), forControlEvents: .ValueChanged)
            controlsView.seekSlider?.addTarget(self, action: #selector(onBeginScrubbing(_:)), forControlEvents: .TouchDown)
            controlsView.seekSlider?.addTarget(self, action: #selector(onEndScrubbing(_:)), forControlEvents: .TouchUpInside)
            controlsView.seekSlider?.addTarget(self, action: #selector(onEndScrubbing(_:)), forControlEvents: .TouchUpOutside)
        }
        
        addTapGestureRecognizer()
    }
    
    // MARK: - ANMediaPlayback
    
    public func play()
    {
        controlsView?.playButton?.hidden = true
        controlsView?.pauseButton?.hidden = false
        
        activityIndicatorView.startAnimating()
        addPlaybackTimeObserver()
        player?.play()
    }
    
    public func pause()
    {
        player?.pause()
        
        controlsView?.playButton?.hidden = false
        controlsView?.pauseButton?.hidden = true
    }
    
    public func stop()
    {
        
    }
    
    public func seekToTime(time: NSTimeInterval)
    {
        
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if context != &playerKVOContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if let player = object as? AVPlayer where player == self.player && keyPath == "status" {
            activityIndicatorView.stopAnimating()
            
            if player.status == .Failed {
                debugPrint(player.error)
            }
            
            updateControlsView()
        } else if keyPath == "frame" {
            playerLayer?.frame = view.bounds
            controlsView?.frame = view.bounds
            activityIndicatorView.center = view.center
        }
    }
    
    // MARK: - Protected
    
    func minutes(totalSeconds: Double) -> Int { return Int(floor(totalSeconds % 3600 / 60)) }
    
    func seconds(totalSeconds: Double) -> Int { return Int(floor(totalSeconds % 3600 % 60)) }
    
    func updateControlsView()
    {
        if let duration = player?.currentItem?.asset.duration {
            let durationTotalSeconds = CMTimeGetSeconds(duration)
            
            controlsView?.totalTimeLabel?.text = String(format: "%02lu:%02lu", minutes(durationTotalSeconds), seconds(durationTotalSeconds))
        }
    }

    func addTapGestureRecognizer()
    {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        tapRecognizer?.cancelsTouchesInView = false
        tapRecognizer?.delegate = self
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func tapGesture(recognizer: UIPanGestureRecognizer)
    {
        controlsView?.hidden = false
        stopHideControllsTimer()
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
        NSTimer.schedule(delay: interval) { [weak self] (timer) in
            self?.controlsView?.hidden = hide
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func onPlayButtonTapped(sender: AnyObject)
    {
        controlsView?.playButton?.hidden = true
        controlsView?.pauseButton?.hidden = false
        
        play()
    }
    
    @IBAction func onPauseButtonTapped(sender: AnyObject)
    {
        stopHideControllsTimer()
        
        controlsView?.playButton?.hidden = true
        controlsView?.pauseButton?.hidden = false
        controlsView?.hidden = false
        
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
