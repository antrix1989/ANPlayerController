//
//  VODItem.swift
//  ANPlayerController
//
//  Created by Sergey Demchenko on 6/15/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import ANPlayerController

class VODItem: NSObject, ANPlayable
{
    // MARK: - ANPlayable
    
    var videoUrl: URL?
    
    var videoThumbnailUrl: URL?
}
