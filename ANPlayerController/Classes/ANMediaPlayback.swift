//
//  ANMediaPlayback.swift
//  Pods
//
//  Created by Sergey Demchenko on 6/14/16.
//
//

import Foundation

/// The ANMediaPlayback protocol defines the interface adopted by player classes for controlling media playback. This protocol supports basic transport operations including start, stop, and pause.

protocol ANMediaPlayback
{
    /// Plays items from the current queue, resuming paused playback if possible.
    func play()
    
    /// Pauses playback if playing.
    func pause()
    
    /// Ends playback. Calling -play again will start from the beginnning of the queue.
    func stop()
    
    /// Seek to a given time.
    func seekToTime(_ time: TimeInterval)
}
