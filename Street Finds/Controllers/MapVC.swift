//
//  MapVC.swift
//  Street Finds
//
//  Created by Mycah on 7/16/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GoogleMobileAds

class MapVC: UIViewController{
    
    @IBOutlet weak var mapViewDisplay: MKMapView!
    @IBOutlet weak var centerBtnDisplay: UIButton!
    @IBOutlet weak var backOrLogoutBtnDisplay: UIButton!
    @IBOutlet weak var bannerDisplay: GADBannerView!
    @IBOutlet weak var infoBtn: UIButton!
    
    var manager : CLLocationManager?
    var regionRadius: CLLocationDistance = 1000
    
    var annoTitle : String = ""
    var annoUID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthStatus()
    
        mapViewDisplay.showsCompass = false
        
        mapViewDisplay.delegate = self
        centerMapOnUserLocation()
        
        //Set padding on info icon
        infoBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        //Set up the ad banner
        //TODO: change this to a DEPLOYMENT adUnitID
        //TEST
        //bannerDisplay.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //Legit
        bannerDisplay.adUnitID = Private().ADMOB_BANNER_ID
        
        bannerDisplay.rootViewController = self
        bannerDisplay.load(GADRequest())
        
        //set image size aspect
        backOrLogoutBtnDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backOrLogoutBtnDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        centerBtnDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        centerBtnDisplay.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        //Make btn round
        centerBtnDisplay.layer.cornerRadius = centerBtnDisplay.frame.size.width / 2
        centerBtnDisplay.clipsToBounds = true
        
        //Check for Vendor movement updates
        DataService.instance.REF_USERS.observe(.value) { (snapshot) in
            self.loadVendorAnnotationsFromFB()
        }
        
        loadVendorAnnotationsFromFB()
       
    }
    
    func checkLocationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            manager?.startUpdatingLocation()
        }else{
            manager?.requestWhenInUseAuthorization()
        }
    }
    
    func loadVendorAnnotationsFromFB(){
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for user in userSnapshot{
                    
                    if user.hasChild("Coordinate"){
                        if user.childSnapshot(forPath: "isActive").value as? Bool == true {
                            
                            //Get the vendor's location info
                            if let vendorDict = user.value as? Dictionary<String, AnyObject>{
                                let coordinateArray = vendorDict["Coordinate"] as! NSArray
                                let vendorCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                
                                let locationTitle = vendorDict["VendorName"] as? String
                                let annoUID = vendorDict["UserID"] as? String
                                //Create the vendors annotation
                                let annotation = VendorAnnotation(coordinate: vendorCoordinate, withKey: user.key, title: locationTitle!, subtitle: annoUID! )
                                
                                //Update the annotation
                                var vendorIsVisible: Bool{
                                    return self.mapViewDisplay.annotations.contains(where: { (annotation) -> Bool in
                                        if let vendorAnnotation = annotation as? VendorAnnotation{
                                            if vendorAnnotation.key == user.key{
                                                vendorAnnotation.update(annotationPosition: vendorAnnotation, withCoordinate: vendorCoordinate)
                                                
                                                return true
                                            }
                                        }
                                        return false
                                    })
                                }
                                
                                if !vendorIsVisible{
                                    self.mapViewDisplay.addAnnotation(annotation)
                                }
                                
                            }
                        }else{
                            for annotation in self.mapViewDisplay.annotations{
                                if annotation.isKind(of: VendorAnnotation.self){
                                    if let annotation = annotation as? VendorAnnotation{
                                        if annotation.key == user.key{
                                            self.mapViewDisplay.removeAnnotation(annotation)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func centerMapOnUserLocation(){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapViewDisplay.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapViewDisplay.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func backOrLogoutBtnPressed(_ sender: Any) {
        //Check if the User came directly from the LoginVC or the VendorProfileVC
        //if user cam from LVC - set button to say "logout", else if user came from VPVC - set button to say "back"
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func centerBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
}

extension MapVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthStatus()
        if status == .authorizedWhenInUse{
            mapViewDisplay.showsUserLocation = true
            mapViewDisplay.userTrackingMode = .follow
        }
    }
}

extension MapVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.tintColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        
        UpdateService.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? VendorAnnotation{
            
            let identifier = "vendor"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "MapIcon")
            view.frame.size = CGSize(width: 40, height: 40)
            
            let annotationLabel = UITextView(frame: CGRect(x: 0 , y: 40, width: 105, height: 20))
            annotationLabel.textAlignment = .center
            annotationLabel.font = UIFont(name: "Avenir Next", size: 12)
            annotationLabel.clipsToBounds = true
            annotationLabel.text = annotation.title!
            annotationLabel.sizeToFit()
            annotationLabel.layer.cornerRadius = 15
            annotationLabel.alpha = 0.80
            view.addSubview(annotationLabel)
            
            //Set constraints
            annotationLabel.translatesAutoresizingMaskIntoConstraints = true
            view.translatesAutoresizingMaskIntoConstraints = true
            annotationLabel.center.x = view.frame.width / 2
            
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.image != nil{
            
            if let viewAnno = view.annotation{
                if let viewAnnoTitle = viewAnno.title as? String, let viewAnnoUID = viewAnno.subtitle as? String{
                    
                    self.mapViewDisplay.deselectAnnotation(view.annotation, animated: true)
                    annoTitle = viewAnnoTitle
                    annoUID = viewAnnoUID
                
                    performSegue(withIdentifier: "segueVendorModalVC", sender: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapToModal"{
            let destVC = segue.destination as! PrivacyTermsVC
            destVC.receivedInfo = "Look for and click on 'Street Finds Icons' to see more information about the Vendor or to get directions.\n\nBe sure to log in as a Vendor and Activate yourself, if you would like users to find you."
        }else{
            
            //Get the destination
            let destVC = segue.destination as! VendorModalVC
            
            //Send things to the destVC
            destVC.vendorName = annoTitle
            destVC.vendorUID = annoUID
        }
    }
}


