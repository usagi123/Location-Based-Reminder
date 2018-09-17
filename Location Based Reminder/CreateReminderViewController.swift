import UIKit
import SafariServices
import CoreML
import Vision
import Firebase
import CoreGraphics

class CreateReminderViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePickerController: UIImagePickerController!
    lazy var vision = Vision.vision()
    
    @IBOutlet var locationEntryTextView: UITextView?
    @IBOutlet weak var itemEntryTextView: UITextView!
    @IBOutlet weak var latitudeEntryTextView: UITextView!
    @IBOutlet weak var longitudeEntryTextView: UITextView!
    @IBOutlet weak var imageEntryImageView: UIImageView!
    @IBOutlet weak var lblResult: UILabel!
    
    @IBAction func chooseImageByTapping(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
                //realistically, I dont need to catch this since every apple mobile devices have rear camera
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
        
        //For ipad action sheet
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageEntryImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        detectImageContent()
        detectLabels(image: imageEntryImageView.image)
        //        detectCloudLabels(image: imageEntryImageView.image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveContact(_ sender: Any) {
        
        //If any fields are empty, app will reject and pop a alert for user to fill it or cancel creating new entry
        if (itemEntryTextView?.text.isEmpty)! || itemEntryTextView?.text == "" || imageEntryImageView.image == UIImage(named: "ImgHolder.jpeg") {
            
            //            print("No Data")
            let alert = UIAlertController(title: "Blank entry", message: "Please fully filled all details.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in })
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //Let data from the fields saved into Core Data
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newEntry = Item(context: context)
            newEntry.title = itemEntryTextView?.text!
            newEntry.type = lblResult?.text!
            
            //Convert UIImage data to Binary data to save to Core Data
            let img = imageEntryImageView.image
            newEntry.image = UIImageJPEGRepresentation(img!, 1)! as Data
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationEntryTextView?.delegate = self
        itemEntryTextView?.delegate = self
        
        detectImageContent()
        detectLabels(image: imageEntryImageView.image)
        //        detectCloudLabels(image: imageEntryImageView.image)
        
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
    
    //Using ML Kit from Firebase to categorize object and search based on that object
    private enum Constants {
        static let detectionNoResultsMessage = "No results returned."
    }
    
    var resultsText = ""
    
    private func showResults() {
        let resultsAlertController = UIAlertController(
            title: "Detection Results",
            message: nil,
            preferredStyle: .actionSheet
        )
        resultsAlertController.addAction(
            UIAlertAction(title: "OK", style: .destructive) { _ in
                resultsAlertController.dismiss(animated: true, completion: nil)
            }
        )
        resultsAlertController.message = resultsText
        present(resultsAlertController, animated: true, completion: nil)
        print(resultsText)
    }
    
    private func transformMatrix() -> CGAffineTransform {
        guard let image = imageEntryImageView.image else { return CGAffineTransform() }
        let imageViewWidth = imageEntryImageView.frame.size.width
        let imageViewHeight = imageEntryImageView.frame.size.height
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let imageViewAspectRatio = imageViewWidth / imageViewHeight
        let imageAspectRatio = imageWidth / imageHeight
        let scale = (imageViewAspectRatio > imageAspectRatio) ?
            imageViewHeight / imageHeight :
            imageViewWidth / imageWidth
        
        // Image view's `contentMode` is `scaleAspectFit`, which scales the image to fit the size of the
        // image view by maintaining the aspect ratio. Multiple by `scale` to get image's original size.
        let scaledImageWidth = imageWidth * scale
        let scaledImageHeight = imageHeight * scale
        let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
        let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)
        
        var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
        transform = transform.scaledBy(x: scale, y: scale)
        return transform
    }
    
    // An overlay view that displays detection annotations.
    private lazy var annotationOverlayView: UIView = {
        precondition(isViewLoaded)
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    
    func detectLabels(image: UIImage?) {
        let labelDetector = vision.labelDetector()
        
        let visionImage = VisionImage(image: imageEntryImageView.image!)
        
        labelDetector.detect(in: visionImage) { features, error in
            guard error == nil, let features = features, !features.isEmpty else {
                //Nest error if cannot detect label from the image
                let errorString = error?.localizedDescription ?? Constants.detectionNoResultsMessage
                self.resultsText = "On-Device label detection failed with error: \(errorString)"
                self.showResults()
                return
            }
            
            //Parse data from features array list of hashed data consist of "label, confidence, entityID and frame" into normal data
            let firstResult = features.first //take the first result only, replace features.map below into firstResult.map + remove .joined at the end as there is only 1 label left
            self.resultsText = firstResult.map { feature -> String in
                let transformedRect = feature.frame.applying(self.transformMatrix())
                UIUtilities.addRectangle(
                    transformedRect,
                    to: self.annotationOverlayView,
                    color: UIColor.green
                )
                self.lblResult.text = "Type: " + String(describing: feature.label)
                return "Label: \(String(describing: feature.label)), " +
                    "Confidence: \(feature.confidence), " +
                    "EntityID: \(String(describing: feature.entityID)), " +
                "Frame: \(feature.frame)"
                }!
            //                .joined(separator: "\n")
            //            self.showResults()
        }
    }
    
    func detectCloudLabels(image: UIImage?) {
        // [START init_label_cloud]
        let labelDetector = vision.cloudLabelDetector()
        // Or, to change the default settings:
        // let labelDetector = Vision.vision().cloudLabelDetector(options: options)
        // [END init_label_cloud]
        
        let visionImage = VisionImage(image: imageEntryImageView.image!)
        
        // [START detect_label_cloud]
        labelDetector.detect(in: visionImage) { labels, error in
            guard error == nil, let labels = labels, !labels.isEmpty else {
                // [START_EXCLUDE]
                let errorString = error?.localizedDescription ?? Constants.detectionNoResultsMessage
                self.resultsText = "Cloud label detection failed with error: \(errorString)"
                self.showResults()
                // [END_EXCLUDE]
                return
            }
            
            // Labeled image
            // START_EXCLUDE
            self.resultsText = labels.map { label -> String in
                "Label: \(String(describing: label.label ?? "")), " +
                    "Confidence: \(label.confidence ?? 0), " +
                "EntityID: \(label.entityId ?? "")"
                }.joined(separator: "\n")
            self.showResults()
            // [END_EXCLUDE]
        }
    }
    
    //Using Core ML model to suggest "buy" label
    func detectImageContent() {
        lblResult.text = "Thinking"
        
        guard let model = try? VNCoreMLModel(for: Food101().model) else {
            fatalError("Failed to load model") //debug mode only, will use actionsheet later
        }
        
        //Create a vision request
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Unexpected result") //same, only for debug
            }
            
            //Update the main UI Thread with result
            DispatchQueue.main.async { [weak self] in
                let resultString = topResult.identifier
                let normalString = resultString.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
                //                self?.lblResult.text = "Detect object as \(topResult.identifier) with \(Int(topResult.confidence * 100))% confidence"
                self?.itemEntryTextView?.text = "Buy \(normalString)"
                GlobalVariables.titleIdentifier = normalString
            }
        }
        
        guard let ciImage = CIImage(image: self.imageEntryImageView.image!) else {
            fatalError("Cannot create CIImage from UIImage") //debug error
        }
        
        //Run classifier
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}


