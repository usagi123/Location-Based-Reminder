//
//  RoundedButton.swift
//  Location Based Reminder
//
//  Created by Mai Pham Quang Huy on 9/1/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit

/// A simple UIButton subclass which displays a rounded border.
class RoundedButton: UIButton {
    override var bounds: CGRect {
        didSet(oldBounds) {
            // Whenever the bounds change.
            if oldBounds.height != bounds.height {
                // Update the layer appearance.
                layer.cornerRadius = bounds.size.height/2
                
                // And notify the autolayout engine that our intrinsic width has changed.
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.style()
    }
    
    private func style() {
        // We want a 1px thin white border.
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    /// Expand the default intrinsicContentSize so that the corners look nice.
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        // Add some padding to the left and right
        size.width += bounds.height
        return size
    }
}
