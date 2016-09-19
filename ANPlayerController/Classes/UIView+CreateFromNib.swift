//
//  UIView+CreateFromNib.swift
//
//  Created by Sergey Demchenko on 11/5/15.
//  Copyright © 2015 antrix1989. All rights reserved.
//

import UIKit

extension UIView
{
    public class func createFromNib<T>() -> T
    {
        let nibName = NSStringFromClass(self).components(separatedBy: ".").last!
        let bundle = Bundle(for: self)
        let nibObjects = bundle.loadNibNamed(nibName, owner: self, options: nil)
        return nibObjects!.first as! T
    }
}
