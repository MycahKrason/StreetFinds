//
//  VendorEditInfoVC.swift
//  Street Finds
//
//  Created by Mycah on 7/22/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase

class VendorEditInfoVC: UIViewController, UITextViewDelegate {

    //Outlets
    @IBOutlet weak var vendorNameTextField: UITextView!
    @IBOutlet weak var vendorDescriptionTextField: UITextView!
    @IBOutlet weak var backBtnDisplay: UIButton!
    
    let currentUser = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vendorNameTextField.delegate = self
        vendorDescriptionTextField.delegate = self
        
        //set image size aspect
        backBtnDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backBtnDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        //Change Return to Send on the keyboard
        vendorDescriptionTextField.returnKeyType = UIReturnKeyType.done
        vendorNameTextField.returnKeyType = UIReturnKeyType.done
        
        self.vendorNameTextField.becomeFirstResponder()
        
        //Grab existing text if any exists
        grabExistingText()
        
    }
    
    //This will grab any existing text if there is any
    func grabExistingText(){
        if let user = currentUser{
            DataService.instance.REF_USERS.child(user).observeSingleEvent(of: .value) { (snapshot) in
                
                if snapshot.exists(){
                    let vendorDescript = snapshot.childSnapshot(forPath: "VendorDescription")
                    let vendorName = snapshot.childSnapshot(forPath: "VendorName")
                    
                    if let vendorD : String = vendorDescript.value as? String {
                        self.vendorDescriptionTextField.text = vendorD
                    }else{
                        self.vendorDescriptionTextField.text = ""
                    }
                    
                    if let vendorN : String = vendorName.value as? String{
                        self.vendorNameTextField.text = vendorN
                    }else{
                        self.vendorNameTextField.text = ""
                    }
                    
                }else{
                    self.vendorDescriptionTextField.text = ""
                    self.vendorNameTextField.text = ""
                }
            }
        }
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            
            if vendorNameTextField.text.count < 145 && vendorDescriptionTextField.text.count < 170{
                
                //update both values in FB
                if let user = currentUser{
                    DataService.instance.REF_USERS.child(user).updateChildValues(["VendorDescription" : vendorDescriptionTextField.text, "VendorName": vendorNameTextField.text])
                    
                    dismiss(animated: true, completion: nil)
                    
                    textView.resignFirstResponder()
                    return false
                }
            }else{
                
                //show alert
                let alertController = UIAlertController(title: nil, message:"Description must be less than 170 characters", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                print("Too many characters")
                return false
            }
        }
        return true
    }
}

