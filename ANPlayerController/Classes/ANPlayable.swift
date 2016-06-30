//
//  ANPlayable.swift
//  Pods
//
//  Created by Sergey Demchenko on 6/14/16.
//
//

import Foundation

public protocol ANPlayable
{
    var videoUrl: NSURL? { get }
    
    var videoThumbnailUrl: NSURL? { get }
}