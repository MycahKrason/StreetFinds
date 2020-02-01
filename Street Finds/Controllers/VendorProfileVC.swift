//
//  VendorVC.swift
//  Street Finds
//
//  Created by Mycah on 7/16/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class VendorProfileVC: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var isActiveBtn: UISwitch!
    @IBOutlet weak var isActiveDisplay: UILabel!
    @IBOutlet weak var vendorNameDisplay: UILabel!
    @IBOutlet weak var vendorDescriptionDisplay: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var uploadImageText: UILabel!
    @IBOutlet weak var viewMapBtnDisplay: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    
    let userID = Auth.auth().currentUser?.uid
    let locationManager = CLLocationManager()
    var regionRadius: CLLocationDistance = 1000
    
    var coordinateForNonMoving : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Set padding on info icon
        infoBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        checkLocationAuthStatus()
        handleIsActive()
        getProfileDescriptionName()
        getProfileImage()
        
        //round corners for signin button
        viewMapBtnDisplay.layer.cornerRadius = 8.0
        viewMapBtnDisplay.clipsToBounds = true
        profileImage.layer.cornerRadius = 8.0
        profileImage.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Because the description modification view is a modal, when updating, the previous page must change when viewed
        getProfileDescriptionName()
    }
    
    func getProfileDescriptionName(){
        if let user = userID{
            DataService.instance.REF_USERS.child(user).observeSingleEvent(of: .value) { (snapshot) in
                
                if !snapshot.exists() {
                    return
                }
                
                //Get Vendor info from FB
                let vendorDescript = snapshot.childSnapshot(forPath: "VendorDescription")
                let vendorName = snapshot.childSnapshot(forPath: "VendorName")
                
                if let vendorD : String = vendorDescript.value as? String {
                    self.vendorDescriptionDisplay.text = vendorD
                }else{
                    self.vendorDescriptionDisplay.text = "Describe what you sell or do."
                }
                
                if let vendorN : String = vendorName.value as? String{
                    self.vendorNameDisplay.text = vendorN
                }else{
                    self.vendorNameDisplay.text = "Vendor Name"
                }
                
            }
        }
    }
    
    func getProfileImage(){
        if let user = userID{
            DataService.instance.REF_USERS.child(user).observeSingleEvent(of: .value) { (snapshot) in
                
                if !snapshot.exists() {
                    return
                }
                
                //Get Vendor info from FB
                let vendorImage = snapshot.childSnapshot(forPath: "VendorImage")
                
                //TODO: Wont be sure this works until we have set images to store
                if let vendorI = vendorImage.value as? String{
                    self.uploadImageText.isHidden = true
                    print("URL@@@@@@@@@@@@@@@@@ \(vendorI)")
                    let url = URL(string: vendorI)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        
                        if error != nil{
                            print(error!)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.profileImage.image = UIImage(data: data!)
                        }
                       
                    }).resume()
                    
                }else{
                    print("No profile Image")
                }
               
            }
        }
    }
    
    func handleIsActive(){
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if snap.key == Auth.auth().currentUser?.uid{
                        let switchStatus = snap.childSnapshot(forPath: "isActive").value as! Bool
                        if switchStatus{
                            self.isActiveBtn.isOn = switchStatus
                            self.isActiveDisplay.text = "Deactivate"
                        }else{
                            self.isActiveBtn.isOn = switchStatus
                            self.isActiveDisplay.text = "Activate"
                        }
                        
                    }
                }
            }
        }
    }
    
    func checkLocationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
        }else{
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get Location
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            
            //Turn location manager off if the user is not active
            //Stop updating the location so you don't kill the User's battery
            //locationManager.stopUpdatingLocation()
            
            UpdateService.instance.updateUserLocation(withCoordinate: location.coordinate)
            coordinateForNonMoving = location.coordinate
        }
    }
    
    @IBAction func isActiveToggle(_ sender: Any) {
        
        if isActiveBtn.isOn{
            isActiveDisplay.text = "Deactivate"
            DataService.instance.REF_USERS.child(userID!).updateChildValues(["isActive": true])
            
            UpdateService.instance.updateUserLocation(withCoordinate: coordinateForNonMoving!)
            
        }else{
            isActiveDisplay.text = "Activate"
            DataService.instance.REF_USERS.child(userID!).updateChildValues(["isActive": false])
        }
        
    }
    
    @IBAction func logOutBtnPressed(_ sender: Any) {
        dismiss(animated: true) {
            DataService.instance.REF_USERS.child(self.userID!).updateChildValues(["isActive": false])
        }
    }
    
    @IBAction func viewMapBtnPressed(_ sender: Any) {
        
    }
    
    //Select an image and upload it
    //This will set up the Image Picker functionality - be sure to add Privacy - Photo Library Usage Description
    @IBAction func uploadImageBtnPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //Do something with the image you choose
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        //This is incase the user edits the image or not
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        //now that we know whether they have editted the photo or not
        if let selectedImage = selectedImageFromPicker{
            self.uploadImageText.isHidden = true
            profileImage.image = selectedImage
            
            //Get a unique ID - insert this into the database name if you want to store EVERY photo a person uploads, otherwise the code as it is now will just rewrite the current image (saving us storage space)
            
            //Save the image to the DB
            let addPhoto = DataService.instance.REF_STBASE.child(userID!)
            
            if let uploadData = UIImagePNGRepresentation(profileImage.image!){
                addPhoto.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil{
                        print(error!)
                        return
                    }
                    addPhoto.downloadURL(completion: { (url, error) in
                        if let error = error {
                            print(error)
                        } else {
                           
                            let urlPath = url?.absoluteString
                            DataService.instance.REF_USERS.child(self.userID!).updateChildValues(["VendorImage" : urlPath!])
                        }
                    })
                
                    print("Photo has been uploaded!")
                    
                })
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Cancel out the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vendorToModal"{
            let destVC = segue.destination as! PrivacyTermsVC
            destVC.receivedInfo = "This is your Vendor Profile Page. Upload or Update your public image by clicking on the image box. \n\nYou may also modify your Vendor Name and Description by clicking on 'Edit Info'. \n\nIf you would like to be visible on the map, so users can find you, toggle the 'Activate' switch to ON. \n\nIf you press 'Logout', or sign in as a customer, you will automatically be 'Deactivated' and users will not be able to see your location."
        }
    }  
}
