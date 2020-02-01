//
//  DataService.swift
//  Street Finds
//
//  Created by Mycah on 7/11/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

let DB_BASE = Database.database().reference()
let ST_BASE = Storage.storage().reference(forURL: Private().FIREBASE_STORAGE_URL)

class DataService{
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_STBASE = ST_BASE
    
    //Reference for Users and Vendors
    private var _REF_USERS = DB_BASE.child("Users")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_STBASE: StorageReference{
        return _REF_STBASE
    }
    
    var REF_USERS: DatabaseReference{
        return _REF_USERS
    }
    
    func createFBDBUser(uid: String, userData: Dictionary<String, Any>){
        
        REF_USERS.child(uid).updateChildValues(userData)
    
    }
}
