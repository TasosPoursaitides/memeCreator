//
//  ViewController.swift
//  memeCreator
//
//  Created by Anastasios Poursaitedes on 16/8/20.
//  Copyright © 2020 Anastasios Poursaitedes. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //This structure Creates a meme with the specified characteristics such as its top and bottom text and the original image.
    struct Meme {
        private let topText: String
        private let bottomText: String
        private let originalImage: UIImage
        private let memedImage: UIImage
        
        init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
            self.topText = topText
            self.bottomText = bottomText
            self.originalImage = originalImage
            self.memedImage = memedImage
        }
        
        init() {
            self.topText = ""
            self.bottomText = ""
            self.originalImage = UIImage()
            self.memedImage = UIImage()
        }
    }
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbal: UIToolbar!
    @IBOutlet weak var memeView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    private lazy var meme: Meme! = Meme()
    
    //We initialize a private constant to be an instance of the TextFieldDelegate class
    private let textFieldDelegate = TextFieldDelegate()
    
    //These are attributes for the text field's text to look like a meme text.
    private let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 50)!,
        NSAttributedString.Key.strokeWidth : 5.0
    ]
    
    
    //Here we hide the toolbar and navigation bar so that we can grab a snapshot of the view. This snapshot is the memedImage that we returned.
    func generateMemedImage() -> UIImage {
        navigationBar.isHidden = true
        toolbal.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        navigationBar.isHidden = false
        toolbal.isHidden = false
        return memedImage
    }
    
    //This function creates a new meme
    func save() {
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memeView.image!, memedImage: generateMemedImage())
    }
    
    /*
     This function creates the image picker controller and sets its source type
     depending the button that was pressed in the toolbar(Either the camera of photo library buttons)
     */
    private func createImagePickerFrom(sourceType type: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //If the camera is not available on the phone(Maybe we run the app on the simulator) set the source to photoLibrary
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(type) ? type : .photoLibrary
        toggleShareButton(isEnabled: UIImagePickerController.isSourceTypeAvailable(.camera))
        present(imagePicker, animated: true)
    }
    
    //When the user picks an image this function run to indicate the completion of the action.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //If we've picked an image set the image view to that image and enable the share button.
        if let image = info[.originalImage] as? UIImage {
            memeView.image = image
            toggleShareButton(isEnabled: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func setTextOfTextFields() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    //This function disables or enables the share button depending on the state of the app
    private func toggleShareButton(isEnabled: Bool) {
        self.shareButton.isEnabled = isEnabled
    }
    
    
    //Some initial setup for the text fields' text(The initial text, their attributes, delegate and text alignment)
    private func textFieldSetup() {
        setTextOfTextFields()
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        topTextField.delegate = textFieldDelegate
        bottomTextField.delegate = textFieldDelegate
    }
    
    /*
     We take the keyboard height by searching the notification which has the necessary info in its user info property.
     */
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    //This function will be called when the keyboard appears on the view.
    @objc func keyboardWillShow(_ notification: Notification) {
        /*
         If the top text field has the tag 2 it means that this is the one we've begin editing so
         we don't have to slide the view up.
         It was the most easy way to implement this in order to avoid having the top text field
         hiding when the view slides up.
         */
        if topTextField.tag == 2 {
            topTextField.tag = 0
        } else {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    //Reset the y origin back to its initial state to bring the view back down.
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    //Subscribing to keyboard notifications.
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //Unsubscribeing to keyboard notifications.
    func unsubscribeToKeyboardNotifitions() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //At the start of the app the text fields will be set to have the initial text
        textFieldSetup()
        //There's no reason the share button to be active when we haven't completed the meme.
        toggleShareButton(isEnabled: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //If the device has a camera the camera button is enabled
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
//        //Scale the image to fit the view
//        memeView.contentMode = .scaleAspectFit
        memeView.backgroundColor = .darkGray
        //Subscribing to keyboards notifications
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifitions()
    }
    
    /*
     This action is connected to the camera and Photo library buttons.
     Those buttons have each a discriptive title so as to determine the source type that will be used on the
     image Picker. If we press the camera button and the device has a camera we will take a picture for the meme
     otherwise we will choose a picture from the photo library.
     */
    @IBAction func pickOrTakeAnImage(_ sender: UIBarButtonItem) {
        let type = sender.title == "camera" ? 1 : 0
        createImagePickerFrom(sourceType: UIImagePickerController.SourceType(rawValue: type)!)
    }
    
    //This function resets the view to its initial state
    @IBAction func cancelMeme(_ sender: UIBarButtonItem) {
        memeView.image = nil
        toggleShareButton(isEnabled: false)
        setTextOfTextFields()
    }
    
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(controller, animated: true)
        
        //When the action is completed we save the meme and dismiss the controller.
        controller.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

}

