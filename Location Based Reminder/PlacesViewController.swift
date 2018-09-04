//
//  PlacesViewController.swift
//  Location Based Reminder
//
//  Created by Mai Pham Quang Huy on 9/2/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftyJSON
import CoreData

class PlacesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // An array to hold the list of possible locations.
    // TODO: create a switch case for all label types google places support
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    var lengthOfArray: Int = 0

    var placesResult: [GMSPlace] = []
    
    // Cell reuse id (cells that scroll out of view can be reused).
    let cellReuseIdentifier = "cell"
    
    var item: Item!
    var visionType: String?
    var visionType1 = ""
    var visionType2 = ""
    
    func determineType() {

        if visionType?.contains("Food") == true {
            visionType1 = "supermarket"
            visionType2 = "shopping_mall"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesResult.removeAll()
        
        // Register the table view cell class and its reuse id.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller provides delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Sorting based on types that contains keywords
        for i in 0..<likelyPlaces.count {
            
            if ((likelyPlaces[i].types.contains(GlobalVariables.visionType1) || likelyPlaces[i].types.contains(GlobalVariables.visionType2)  || likelyPlaces[i].types.contains(GlobalVariables.visionType3) || likelyPlaces[i].types.contains(GlobalVariables.visionType4)) && !placesResult.contains(likelyPlaces[i])) {
                placesResult.append(likelyPlaces[i])
            }
        }
        likelyPlaces.removeAll()
        likelyPlaces = placesResult
        GlobalVariables.lat = likelyPlaces[0].coordinate.latitude
        GlobalVariables.long = likelyPlaces[0].coordinate.longitude
        tableView.reloadData()
    }
    
    // Pass the selected place to the new view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMain" {
            if let nextViewController = segue.destination as? MapViewController {
                nextViewController.selectedPlace = selectedPlace
            }
        }
    }
}

// Respond when a user selects a place.
extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = likelyPlaces[indexPath.row]
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
}

// Populate the table with the list of most likely places.
extension PlacesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let collectionItem = likelyPlaces[indexPath.row]
        
        cell.textLabel?.text = collectionItem.name
        
        return cell
    }
    
    // Adjust cell height to only show the first five items in the table
    // (scrolling is disabled in IB).
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height/5
    }
    
    // Make table rows display at proper height if there are less than 5 items.
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == tableView.numberOfSections - 1) {
            return 1
        }
        return 0
    }
}
