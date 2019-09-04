//
//  Bar.swift
//  diveBarv3
//
//  Created by Alicia MacCara on 9/2/19.
//  Copyright © 2019 Alicia MacCara. All rights reserved.
//

import Foundation
import MapKit

class Bar: NSObject, MKAnnotation  {
    var coordinate: CLLocationCoordinate2D
    var barRating: String
    var barPrice: String
    var title: String?
    var barImage: String
    var barDescription: String
    
    init(coordinate: CLLocationCoordinate2D, barRating: String, barPrice: String, title:String, barDescription:String, barImage:String)
    {
        self.coordinate = coordinate
        self.barRating = barRating
        self.barPrice = barPrice
        self.title = title
        self.barDescription = barDescription
        self.barImage=barImage
    }
}

