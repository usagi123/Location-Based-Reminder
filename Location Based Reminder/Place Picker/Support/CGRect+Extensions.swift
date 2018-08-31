//
//  CGRect+Extensions.swift
//  Location Based Reminder
//
//  Created by Mai Pham Quang Huy on 9/1/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import CoreGraphics

extension CGRect {
    var center: CGPoint {
        get {
            return CGPoint(x: origin.x+size.width/2, y: origin.y+size.height/2)
        }
    }
}

