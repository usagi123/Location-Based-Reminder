//
//  BaseContainerViewController.swift
//  Location Based Reminder
//
//  Created by Mai Pham Quang Huy on 9/1/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit

/// Base view controller for the two container view controllers in the demo. This class monitors the
/// current traitCollection and provides a property |actualTraitCollection| which can be used to
/// access the most recent trait collection.
class BaseContainerViewController: UIViewController {
    private var _actualTraitCollection: AnyObject? = nil
    
    /// Retrieve the most recent trait collection. This will usually be the same as |traitCollection|
    /// but will differ during trait transitions. During a trait transition |traitCollection| will
    /// still have the old value of the trait collection, whereas |actualTraitCollection| will store
    /// the value of the new trait collection.
    internal var actualTraitCollection: UITraitCollection {
        get {
            if let collection = _actualTraitCollection as? UITraitCollection {
                return collection
            }
            return traitCollection
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Monitor for trait collection changes so |actualTraitCollection| can be kept up to date.
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        _actualTraitCollection = newCollection
        super.willTransition(to: newCollection, with: coordinator)
    }
}
