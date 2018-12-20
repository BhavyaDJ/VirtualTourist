//
//  PinAnnotations.swift
//  VirtualTourist
//
//  Created by Bhavya D J on 01/12/18.
//  Copyright © 2018 Bhavya D J. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import UIKit

class PinAnnotation: NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
    var associatedPin: Pin!
}
