//
//  PlaceAttributeCell.swift
//  Location Based Reminder
//
//  Created by Mai Pham Quang Huy on 9/1/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit

/// A cell which displays the name and value of an attribute on |GMSPlace|.
class PlaceAttributeCell: UITableViewCell {
    static let nib = { UINib(nibName: "PlaceAttributeCell", bundle: nil) }()
    static let reuseIdentifier = "PlaceAttributeCell"
    @IBOutlet weak var propertyName: UILabel!
    @IBOutlet weak var propertyValue: UILabel!
    @IBOutlet weak var propertyIcon: UIImageView!
}

