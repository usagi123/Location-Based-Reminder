import UIKit
import SafariServices

struct GlobalVariables {
    static var titleIdentifier: String = String()
    static var lat: Double = Double()
    static var long: Double = Double()
    static var visionType: String = String()
    static var visionType1: String = String()
    static var visionType2: String = String()
    static var visionType3: String = String()
    static var visionType4: String = String()
}

class EditReminderViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var item: Item!
    var editToggle: Bool = false
    
    func determineType() {
        GlobalVariables.visionType = item.type!
        GlobalVariables.titleIdentifier = item.title!
        
        if GlobalVariables.visionType.contains("Food") || GlobalVariables.visionType.contains("Fruit") || GlobalVariables.visionType.contains("Vegetable") {
            GlobalVariables.visionType1 = "supermarket"
            GlobalVariables.visionType2 = "shopping_mall"
            GlobalVariables.visionType3 = "convenience_store"
            GlobalVariables.visionType4 = "department_store"
        }
    }
    
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
                if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
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
        
        titleText.isEditable = true
        imageView.isUserInteractionEnabled = true
    }
    
    func textFieldDeactive() {
        
        titleText.isEditable = false
        imageView.isUserInteractionEnabled = false
    }
    
    @IBOutlet weak var updateHeadingOutlet: UILabel!
    @IBOutlet weak var updateActionOutlet: UIButton!
    @IBAction func updateAction(_ sender: Any) {
        
        switch editToggle {
        case false:
            //Switch to edit mode when Edit button was pressed
            guard let newTitle = titleText.text,
                let newImage = imageView.image else  {
                    return
            }
            
            //Assign which attribute belong to which entity so they can load correctly into their field (Read)
            item.title = newTitle
            item.image = newImage.jpegData(compressionQuality: 1)! as Data //Convert Binary data from Core Data to UIImage data for display
            
            updateHeadingOutlet.text = "Update Song"
            updateActionOutlet.setTitle("Update", for: UIControl.State.normal)
            textFieldActive()
            editToggle = true
        case true:
            guard let newTitle = titleText.text,
                let newImage = imageView.image else  {
                    return
            }
            
            //If one field is empty then alert user to fully filled it before saving
            if ((titleText?.text.isEmpty)! || (locationText?.text.isEmpty)!) {
                
                let alert = UIAlertController(title: "Blank field", message: "Please fully filled all details", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
                
                self.present(alert, animated: true, completion: nil)
            } else {
                
                //Save new data from inside all fields back to Core Data (Update)
                item.title = newTitle
                item.image = newImage.jpegData(compressionQuality: 1)! as Data
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                //Switch back to view mode after press Update button
                updateHeadingOutlet.text = "View Song"
                updateActionOutlet.setTitle("Edit", for: UIControl.State.normal)
                textFieldDeactive()
                editToggle = false
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        imageView.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleText!.delegate = self
        let img = UIImage(data: item.image! as Data)
        imageView.image = img
        
        configureEntryData(entry: item)
        print(item)
        
        determineType()
        print(GlobalVariables.visionType1)
        print(GlobalVariables.visionType2)
        print(GlobalVariables.lat)
        print(GlobalVariables.long)
        print(GlobalVariables.titleIdentifier)
        
        //Move the UI for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
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
        
        guard let title = entry.title,
            let type = entry.type else {
                return
        }
        
        titleText!.text = title
        GlobalVariables.visionType = type
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
