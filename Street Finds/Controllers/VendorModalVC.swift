//
//  VendorModalVC.swift
//  Street Finds
//
//  Created by Mycah on 7/24/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class VendorModalVC: UIViewController {

    //Outlets
    @IBOutlet weak var modalMainView: UIView!
    @IBOutlet weak var vendorImage: UIImageView!
    @IBOutlet weak var vendorNameDisplay: UILabel!
    @IBOutlet weak var vendorDescriptionDisplay: UILabel!
    @IBOutlet weak var directionsBtnDisplay: UIButton!
    
    //Retrieved Info from MapVC
    var vendorName : String?
    var vendorUID : String?
    
    var vendorCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //round corners for signin button
        modalMainView.layer.cornerRadius = 8.0
        modalMainView.clipsToBounds = true
        vendorImage.layer.cornerRadius = 8.0
        vendorImage.clipsToBounds = true
        directionsBtnDisplay.layer.cornerRadius = 8.0
        directionsBtnDisplay.clipsToBounds = true
        
        if let vendorNameForDisplay = vendorName{
            vendorNameDisplay.text = vendorNameForDisplay
        }
        vendorNameDisplay.text = vendorName
        
        getUserInfo()
        
    }
    
    func getUserInfo(){
        if let user = vendorUID{
            
            print("$$$$$$$$$$$$$$$$$$$$$ \(user)")
            DataService.instance.REF_USERS.child(user).observeSingleEvent(of: .value) { (snapshot) in
                
                if !snapshot.exists() {
                    return
                }
                
                //Get Vendor info from FB
                let vendorImage = snapshot.childSnapshot(forPath: "VendorImage")
                let vendorDescript = snapshot.childSnapshot(forPath: "VendorDescription")
                if let vendorDict = snapshot.value as? Dictionary<String, AnyObject>{
                    let coordinateArray = vendorDict["Coordinate"] as! NSArray
                    self.vendorCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                }
                
                //Set Vendor Description
                if let vendorD : String = vendorDescript.value as? String {
                    self.vendorDescriptionDisplay.text = vendorD
                }else{
                    self.vendorDescriptionDisplay.text = "Describe what you sell or do."
                }
                
                //Set Vendor Image
                if let vendorI = vendorImage.value as? String{
                    
                    let url = URL(string: vendorI)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        
                        if error != nil{
                            print(error!)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.vendorImage.image = UIImage(data: data!)
                        }
                        
                    }).resume()
                    
                }else{
                    print("No profile Image")
                }
            }
        }
    }
    
    @IBAction func directionsBtnPressed(_ sender: Any) {
        //Open up apple maps and show location
        let regionDistance: CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(vendorCoordinate!, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: vendorCoordinate!)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = vendorName
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
