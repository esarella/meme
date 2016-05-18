//
//  ViewController.swift
//  MeMe
//
//  Created by Emmanuel Sarella on 5/5/16.
//  Copyright © 2016 Emmanuel Sarella. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIScrollViewDelegate ,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var currentTextField: UITextField?
    
    var meme: Meme?
    
    let topPlaceholderText = "TOP"
    let bottomPlaceholderText = "BOTTOM"
    
    let memeImagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memeImagePicker.delegate = self
        
        topText.text = topPlaceholderText
        bottomText.text = bottomPlaceholderText
        
        setTextFieldAttributes(topText)
        setTextFieldAttributes(bottomText)
        
        shareButton.enabled = false
        cancelButton.enabled = false
        
    }
    
    func setTextFieldAttributes(textFeild: UITextField)
    {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.whiteColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : 0
        ]
        
        textFeild.defaultTextAttributes = memeTextAttributes
        textFeild.textAlignment = NSTextAlignment.Center
        textFeild.delegate = self
        textFeild.hidden = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera)
        {
            cameraButton.enabled = true
        }
        else
        {
            cameraButton.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        pickAnImage(.Camera)
    }
    
    @IBAction func albumButtonPressed(sender: AnyObject) {
        pickAnImage(.PhotoLibrary)
        
    }
    
    func pickAnImage(sourceType: UIImagePickerControllerSourceType) {
        memeImagePicker.sourceType = sourceType
        self.presentViewController(memeImagePicker, animated: true, completion: nil)
        
    }
    
    //    func isCameraDeviceAvailable(cameraDevice: UIImagePickerControllerCameraDevice) -> Bool
    //    {
    //
    //    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imagePickerView.image = image
        }
        
        topText.hidden = false
        bottomText.hidden = false
        
        shareButton.enabled = true
        cancelButton.enabled = false
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if currentTextField == bottomText {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hidePlaceholderText(textField)
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        showPlaceholderText(textField)
        currentTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func hidePlaceholderText(textField: UITextField) {
        if textField == topText && textField.text! == topPlaceholderText {
            textField.text = ""
        }
        if textField == bottomText && textField.text! == bottomPlaceholderText {
            textField.text = ""
        }
        cancelButton.enabled = true
        shareButton.enabled = false
    }
    
    private func showPlaceholderText(textField: UITextField) {
        if textField == topText && textField.text! == "" {
            textField.text = topPlaceholderText
        }
        if textField == bottomText && textField.text! == "" {
            textField.text = bottomPlaceholderText
        }
        cancelButton.enabled = true
        shareButton.enabled = true
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        topText.text = topPlaceholderText
        bottomText.text = bottomPlaceholderText
        
        shareButton.enabled = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        meme = Meme(topText: topText.text!, bottomText: bottomText.text!, backgroundImage: imagePickerView.image!, completeImage: generateMemeImage())
    }
    
    func generateMemeImage() -> UIImage {
        
        hideToolbars()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let completeMemeImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        showToolbars()
        
        return completeMemeImage
    }
    
    func hideToolbars()
    {
        topToolbar.hidden = true
        bottomToolbar.hidden = true
    }
    
    func showToolbars()
    {
        topToolbar.hidden = false
        bottomToolbar.hidden = false
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let image = generateMemeImage()
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler = {(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) in
            if completed {
                self.cancelButton.enabled = true
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
}