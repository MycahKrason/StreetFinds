//
//  GradientView.swift
//  Street Finds
//
//  Created by Mycah on 7/14/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit

class GradientView: UIView {

    let gradient = CAGradientLayer()
    
    override func awakeFromNib() {
        setUpGradientView()
    }
    
    func setUpGradientView(){
        
        gradient.frame = self.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 0, y: 1.0)
        gradient.locations = [0.2, 1.0]
        self.layer.addSublayer(gradient)
        
    }

}
