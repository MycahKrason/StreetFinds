//
//  VendorAnnotation.swift
//  Street Finds
//
//  Created by Mycah on 7/18/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import Foundation
import MapKit

class VendorAnnotation: NSObject, MKAnnotation{
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, withKey key: String, title: String, subtitle: String){
        self.coordinate = coordinate
        self.key = key
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
    
    func update(annotationPosition annotation: VendorAnnotation, withCoordinate coordinate: CLLocationCoordinate2D){
        var location = self.coordinate
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        UIView.animate(withDuration: 0.2) {
            self.coordinate = location
        }
    }
}
