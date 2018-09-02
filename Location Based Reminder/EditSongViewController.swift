//
//  EditSongViewController.swift
//  Location Based Reminder
//
//  Created by Mai Pham Quang Huy on 8/20/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit
import SafariServices

class EditSongViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var item: Item!
    var editToggle: Bool = false
    
    @IBOutlet weak var locationText: UITextView!
    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var latitudeText: UITextView!
    @IBOutlet weak var longitudeText: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func checkMapButton(_ sender: Any) {
        performSegue(withIdentifier: "checkMap", sender: self)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseImageByTapping(_ sender: UITapGestureRecognizer) {
        
        switch editToggle {
        case true:
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            
            let actionSheet = UIAlertController(title: "Photo source", message: "Choose a source", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
                if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                } else {
                    print("Error")
                    let alertCamera = UIAlertController(title: "Error", message: "No rear camera detected on this device", preferredStyle: .alert)
                    alertCamera.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertCamera, animated: true, completion: nil)
                }
                
            }))
            actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: {(action: UIAlertAction) in
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            //For ipad
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            self.present(actionSheet, animated: true, completion: nil)
        case false:
            break
        }
    }

    //Prepare field to be editable between edit/view mode
    func textFieldActive() {
        
        locationText.isEditable = true
        titleText.isEditable = true
        latitudeText.isEditable = true
        longitudeText.isEditable = true
        imageView.isUserInteractionEnabled = true
    }
    
    func textFieldDeactive() {
        
        locationText.isEditable = false
        titleText.isEditable = false
        latitudeText.isEditable = false
        longitudeText.isEditable = false
        imageView.isUserInteractionEnabled = false
    }
    
    @IBOutlet weak var updateHeadingOutlet: UILabel!
    @IBOutlet weak var updateActionOutlet: UIButton!
    @IBAction func updateAction(_ sender: Any) {
        
        switch editToggle {
        case false:
            //Switch to edit mode when Edit button was pressed
            guard let newLocation = locationText.text,
                let newTitle = titleText.text,
                let newLatitude = latitudeText.text,
                let newLongitude = longitudeText.text,
                let newImage = imageView.image else  {
                    return
            }
            
            //Assign which attribute belong to which entity so they can load correctly into their field (Read)
            item.location = newLocation
            item.title = newTitle
            item.latitude = newLatitude
            item.longitude = newLongitude
            item.image = UIImageJPEGRepresentation(newImage, 1)! as Data //Convert Binary data from Core Data to UIImage data for display
            
            updateHeadingOutlet.text = "Update Song"
            updateActionOutlet.setTitle("Update", for: UIControlState.normal)
            textFieldActive()
            editToggle = true
        case true:
            guard let newLocation = locationText.text,
                let newTitle = titleText.text,
                let newLatitude = latitudeText.text,
                let newLongitude = longitudeText.text,
                let newImage = imageView.image else  {
                    return
            }
            
            //If one field is empty then alert user to fully filled it before saving
            if ((titleText?.text.isEmpty)! || (locationText?.text.isEmpty)! || (latitudeText?.text.isEmpty)! || (longitudeText?.text.isEmpty)!) {
                
                let alert = UIAlertController(title: "Blank field", message: "Please fully filled all details", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
                
                self.present(alert, animated: true, completion: nil)
                
            } else if Double(latitudeText.text) == nil { //Filter number only in the year field
                
                print("Error, not number input")
                let alert = UIAlertController(title: "Wrong data type", message: "Please type number only", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                //Save new data from inside all fields back to Core Data (Update)
                item.location = newLocation
                item.title = newTitle
                item.latitude = newLatitude
                item.longitude = newLongitude
                item.image = UIImageJPEGRepresentation(newImage, 1)! as Data
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                //Switch back to view mode after press Update button
                updateHeadingOutlet.text = "View Song"
                updateActionOutlet.setTitle("Edit", for: UIControlState.normal)
                textFieldDeactive()
                editToggle = false
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationText!.delegate = self
        titleText!.delegate = self
        latitudeText!.delegate = self
        latitudeText.keyboardType = .numberPad
        let img = UIImage(data: item.image! as Data)
        imageView.image = img
        
        configureEntryData(entry: item)
        print(item)
        
        //Move the UI for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Call Core Data entity and attributes
    func configureEntryData(entry: Item) {
        
        guard let text = entry.location,
            let title = entry.title,
            let latitude = entry.latitude,
            let longitude = entry.longitude else {
                return
        }
        
        locationText!.text = text
        titleText!.text = title
        latitudeText!.text = latitude
        longitudeText!.text = longitude
    }
    
    //View keyboard everytime clicking into field
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    //Press return to finish typing that field
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
