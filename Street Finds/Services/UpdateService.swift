//
//  UpdateService.swift
//  Street Finds
//
//  Created by Mycah on 7/17/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class UpdateService{
    static var instance = UpdateService()
    
    func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D){
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                
                //Parse through all the user to find our user
                for user in userSnapshot{
                    if user.key == Auth.auth().currentUser?.uid {
                        if user.childSnapshot(forPath: "isActive").value as? Bool == true{
                            DataService.instance.REF_USERS.child(user.key).updateChildValues(["Coordinate" : [coordinate.latitude, coordinate.longitude]])
                        }
                    }
                }
            }
        }
    }
}
