//
//  PrivacyTermsVC.swift
//  Street Finds
//
//  Created by Mycah on 7/31/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit

class PrivacyTermsVC: UIViewController {

    //Outlets
    @IBOutlet weak var termsPrivacyDesciption: UITextView!
    
    //received information
    var receivedInfo : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        termsPrivacyDesciption.isScrollEnabled = false
        
        termsPrivacyDesciption.text = receivedInfo

    }
    
    override func viewDidAppear(_ animated: Bool) {
        termsPrivacyDesciption.isScrollEnabled = true
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
