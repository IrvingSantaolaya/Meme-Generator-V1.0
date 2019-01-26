//
//  ViewController.swift
//  Meme Generator
//
//  Created by Irving Martinez on 1/14/19.
//  Copyright © 2019 Irving Martinez. All rights reserved.
//

import UIKit

class MemeGeneratorViewController: UIViewController {
    
    // Outlet to the imageView that will hold the Meme Picture
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    var toolBarsState = true
    
    // Variable will be used to check if the selected textfield is the bottom one
    var activeTextField: UITextField?
    
    
    // Text attributes dictionary for border color, text color, font, size, and borrder width
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Recognizer to dismiss keyboard when user taps away from the keyboard or textfield
        let tapAnywhere = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapAnywhere)
        
        bottomTextField.delegate = self
        topTextField.delegate = self
        textFieldSetup(topTextField)
        textFieldSetup(bottomTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeToKeyboardNotifications()
    }
    
    func textFieldSetup(_ textfield: UITextField) {
        
        
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.textAlignment = .center
        if textfield == topTextField {
            textfield.text = "TOP"
        }
        if textfield == bottomTextField {
            bottomTextField.text = "BOTTOM"
        }
        
    }
    
    // Create the memed image
    func generateMemedImage() -> UIImage {
        bottomToolbar.isHidden = true
        topToolBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        bottomToolbar.isHidden = false
        topToolBar.isHidden = false
        
        return memedImage
    }
    
    // Save the memed image
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let shareController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: [])
        shareController.completionWithItemsHandler = {(activity: UIActivity.ActivityType?, completed: Bool,  [Any]?, error: Error?) in
            if completed == false {
                // User canceled
                return
            }
            // User completed activity
            self.save()
        }
        
        self.present(shareController, animated: true, completion: nil)

        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        imagePickerView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.isEnabled = false
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        activeTextField?.resignFirstResponder()
        
    }

    
    
}




// ImagePicker protocol methods and functions
extension MemeGeneratorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // When the user taps the pick button
    @IBAction func pickFromLibraryButtonPressed(_ sender: Any) {
        
        setupPickerController(sourceType: .photoLibrary)
    }
    
    @IBAction func pickFromCameraButtonPressed(_ sender: Any) {
        
       setupPickerController(sourceType: .camera)
        
    }
    
    func setupPickerController(sourceType: UIImagePickerController.SourceType){
        
        // Create the imagePickerViewController and present it
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        present(pickerController, animated: true, completion: nil)
        
    }
    
    
    // Protocol method to grab the chosen picture using the dictionary key
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Set the imageView to the chosen picture
        if let imageSelection = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = imageSelection
            
        }
        
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    // Protocol method to cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
}




// Text field protocol methods and functions

extension MemeGeneratorViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        textField.text = ""
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()

       
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {

        if topTextField.text == "" {
            topTextField.text = "TOP"
        }
        if bottomTextField.text == "" {
            bottomTextField.text = "BOTTOM"
        }
    }
    
    // Subscribe to listen for the keyboard showing up
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Get the height of the keyboard to know how much to move the view
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
        
    }
    // Move the view up or down, by the size of the keyboard based on notification
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if activeTextField == bottomTextField {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0.0
        
    }
    
    
    
    // Unsubscribe
    func unsubscribeToKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}

