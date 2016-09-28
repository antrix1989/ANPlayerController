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

open class ANPlayerController: NSObject, UIGestureRecognizerDelegate, ANMediaPlayback
{
    open var playable: ANPlayable?
    
    /// The player view.
    open lazy var view: UIView = ({
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 160))
        view.backgroundColor = UIColor.black
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
    open var controlsView: ANPlayerControlsView?
    
    /// Hide controls after interval.
    open var hidingControlsInterval: TimeInterval = 3
    
    /// Video loading indciator view.
    open var activityIndicatorView: UIActivityIndicatorView?
    
    open var onPlayableDidFinishPlayingBlock : ((ANPlayable?) -> Void) = { (playable) -> Void in }
    open var onViewTappedBlock : (() -> Void) = { () -> Void in }
    open var onReadyToPlayBlock : (() -> Void) = { () -> Void in }
    
    open var volume: Float {
        get { return player?.volume ?? 0 }
        set { player?.volume = newValue }
    }
    
    open var isFullScreen = false
    
    open var isPlaying: Bool = false { willSet { self.willChangeValue(forKey: "isPlaying") } didSet { self.didChangeValue(forKey: "isPlaying") } }
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var hideControlsTimer: Timer?
    var restoreAfterScrubbingRate: Float = 0
    var playbackTimeObserver: AnyObject?
    var tapRecognizer: UITapGestureRecognizer?
    var fullScreenViewController: ANFullScreenViewController?
    
    fileprivate var playerKVOContext = 0
    
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
    
    open func mute(_ mute: Bool)
    {
        player?.volume = mute ? 0 : 1
    }
    
    open func prepare()
    {
        removePlayer()
        resetControlsView()
        mute(false)
        
        if let videoUrl = playable?.videoUrl  {
            createPlayer(videoUrl as URL)
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
            
            controlsView.state = .pause
            controlsView.isHidden = true
            
            controlsView.playButton?.addTarget(self, action: #selector(onPlayButtonTapped(_:)), for: .touchUpInside)
            controlsView.pauseButton?.addTarget(self, action: #selector(onPauseButtonTapped(_:)), for: .touchUpInside)
            controlsView.seekSlider?.addTarget(self, action: #selector(onScrub(_:)), for: .valueChanged)
            controlsView.seekSlider?.addTarget(self, action: #selector(onBeginScrubbing(_:)), for: .touchDown)
            controlsView.seekSlider?.addTarget(self, action: #selector(onEndScrubbing(_:)), for: .touchUpInside)
            controlsView.seekSlider?.addTarget(self, action: #selector(onEndScrubbing(_:)), for: .touchUpOutside)
        }
        
        addTapGestureRecognizer()
    }
    
    open func setFullscreen(_ fullscreen: Bool, animated: Bool)
    {
        func closeFullScreenController()
        {
            stop()
            fullScreenViewController?.dismiss(animated: true, completion: { self.isFullScreen = false; })
        }
        
        if fullscreen {
            view.removeFromSuperview()
            fullScreenViewController = ANFullScreenViewController()
            fullScreenViewController!.player = self
            let _ = fullScreenViewController!.view // Load view.
            fullScreenViewController!.fullScreenView.playerContainerView.addSubview(view)
            view.snp_makeConstraints { (make) in
                make.top.equalTo(self.fullScreenViewController!.fullScreenView.playerContainerView.snp_top)
                make.bottom.equalTo(self.fullScreenViewController!.fullScreenView.playerContainerView.snp_bottom)
                make.left.equalTo(self.fullScreenViewController!.fullScreenView.playerContainerView.snp_left)
                make.right.equalTo(self.fullScreenViewController!.fullScreenView.playerContainerView.snp_right)
            }
            
            fullScreenViewController!.onCloseButtonTapped = { () -> Void in
                closeFullScreenController()
            }
            
            isFullScreen = true
            UIApplication.shared.keyWindow?.rootViewController?.present(fullScreenViewController!, animated: animated, completion: nil)
        } else {
            closeFullScreenController()
        }
    }
    
    // MARK: - ANMediaPlayback
    
    open func play()
    {
        controlsView?.state = .play
        
        activityIndicatorView?.startAnimating()
        addPlaybackTimeObserver()
        player?.play()
        
        isPlaying = true
    }
    
    open func pause()
    {
        stopHideControllsTimer()
        
        controlsView?.state = .pause
        controlsView?.isHidden = false
        
        player?.pause()
        
        isPlaying = false
    }
    
    open func stop()
    {
        player?.pause()
        seekToTime(0)
        resetControlsView()
        
        isPlaying = false
    }
    
    open func seekToTime(_ time: TimeInterval)
    {
        player?.seek(to: CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)))
    }
    
    // MARK: - KVO
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if context != &playerKVOContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if let player = object as? AVPlayer , player == self.player && keyPath == "status" {
            activityIndicatorView?.stopAnimating()
            
            if player.status == .failed {
                debugPrint(player.error)
            } else if player.status == .readyToPlay {
                onReadyToPlayBlock()
            }
            
            updateControlsView()
        } else if keyPath == "bounds" {
            playerLayer?.frame = view.bounds
        }
    }
    
    // MARK: - Protected
    
    func onItemDidFinishPlayingNotification(_ notification: Notification)
    {
        onPlayableDidFinishPlayingBlock(playable)
    }
    
    func createPlayer(_ contentVideoUrl: URL)
    {
        let playerItem = AVPlayerItem(url: contentVideoUrl)
        NotificationCenter.default.addObserver(self, selector: #selector(onItemDidFinishPlayingNotification(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
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
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
        
        player?.removeObserver(self, forKeyPath: "status")
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        removePlaybackTimeObserver()
    }
    
    func minutes(_ totalSeconds: Double) -> Int { return Int(floor(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)) }
    
    func seconds(_ totalSeconds: Double) -> Int { return Int(floor(totalSeconds.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))) }
    
    func resetControlsView()
    {
        setCurrentTimeLabelValue(kCMTimeZero)
        controlsView?.state = .pause
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
    
    func setCurrentTimeLabelValue(_ time: CMTime)
    {
        let currentTimeTotalSeconds = CMTimeGetSeconds(time)
        
        controlsView?.currentTimeLabel?.text = String(format: "%02lu:%02lu", minutes(currentTimeTotalSeconds), seconds(currentTimeTotalSeconds))
    }
    
    func addPlaybackTimeObserver()
    {
        if let _ = playbackTimeObserver { return }
        
        let interval = CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC)) // 1 second
        playbackTimeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { [weak self] (time) in
            if let rate = self?.player?.rate , rate == 0 { return }
            
            self?.setCurrentTimeLabelValue(time)
            
            let currentTimeTotalSeconds = CMTimeGetSeconds(time)
            self?.controlsView?.seekSlider?.value = Float(currentTimeTotalSeconds)
        }) as AnyObject?
    }
    
    func hideControlsView(_ hide: Bool, afterInterval interval: TimeInterval)
    {
        hideControlsTimer = Timer.schedule(delay: interval) { [weak self] (timer) in
            self?.controlsView?.isHidden = hide
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
    
    func onTapGesture(_ recognizer: UITapGestureRecognizer)
    {
        onViewTappedBlock()
        controlsView?.isHidden = false
        stopHideControllsTimer()
        if let controlsView = controlsView , hideControlsTimer == nil && !controlsView.isHidden {
            hideControlsView(true, afterInterval: hidingControlsInterval)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        return view == touch.view
    }
    
    // MARK: - IBAction
    
    @IBAction func onPlayButtonTapped(_ sender: AnyObject)
    {
        play()
    }
    
    @IBAction func onPauseButtonTapped(_ sender: AnyObject)
    {
        pause()
    }
    
    /// User is dragging the movie controller thumb to scrub through the movie.
    
    @IBAction func onBeginScrubbing(_ slider: UISlider)
    {
        stopHideControllsTimer()
        
        if let player = player {
            restoreAfterScrubbingRate = player.rate
            player.rate = 0
        }
        
        removePlaybackTimeObserver()
    }
    
    @IBAction func onScrub(_ slider: UISlider)
    {
        if let playerDuration = player?.currentItem?.asset.duration , CMTIME_IS_INVALID(playerDuration) { return }
        
        if let timeScale = player?.currentItem?.asset.duration.timescale {
            let time = CMTimeMakeWithSeconds(Float64(slider.value), timeScale)
            player?.seek(to: time)
            setCurrentTimeLabelValue(time)
        }
    }
    
    @IBAction func onEndScrubbing(_ slider: UISlider)
    {
        if restoreAfterScrubbingRate != 0 {
            player?.rate = restoreAfterScrubbingRate
            restoreAfterScrubbingRate = 0
        }
        
        addPlaybackTimeObserver()
        hideControlsView(true, afterInterval: hidingControlsInterval)
    }
}
