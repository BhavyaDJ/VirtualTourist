//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Bhavya D J on 01/12/18.
//  Copyright © 2018 Bhavya D J. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapImage: MKMapView!

    //MARK: Properties
    var dataController: DataController!
    var allPins: [Pin] = []
    var currentPin: Pin!
    var pinHasPhotos: Bool!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapImage.delegate = self
        let scale = MKScaleView(mapView: mapImage)
        scale.isHidden = false
        mapImage.addSubview(scale)
        
        //load the mapView zoom level and center point from last time user was in the view
        let defaults = UserDefaults.standard
        if let lat = defaults.value(forKey: "lat"),
            let lon = defaults.value(forKey: "lon"),
            let latDelta = defaults.value(forKey: "latDelta"),
            let lonDelta = defaults.value(forKey: "lonDelta") {
            
            let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat as! Double, longitude: lon as! Double)
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta as! Double, longitudeDelta: lonDelta as! Double)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
            mapImage.setRegion(region, animated: true)
        }
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            allPins = result
        }
        
        //Add allPins to the map for the user to see
        for pin in allPins {
            let annotation = PinAnnotation()
            annotation.setCoordinate(newCoordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
            annotation.associatedPin = pin
            self.mapImage.addAnnotation(annotation)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //save mapView zoom level and center point as user exits view
        let defaults = UserDefaults.standard
        defaults.set(self.mapImage.centerCoordinate.latitude, forKey: "lat")
        defaults.set(self.mapImage.centerCoordinate.longitude, forKey: "lon")
        defaults.set(self.mapImage.region.span.latitudeDelta, forKey: "latDelta")
        defaults.set(self.mapImage.region.span.longitudeDelta, forKey: "lonDelta")
    }
    
    @IBAction func droppingPin(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began { return}
            
            let location = sender.location(in: self.mapImage)
            let coordinates = self.mapImage.convert(location, toCoordinateFrom: self.mapImage)
            
            //place pin on the map where user long presses
            let annotation = PinAnnotation()
            annotation.setCoordinate(newCoordinate: coordinates)
            self.mapImage.addAnnotation(annotation)
            
            //create Pin to be saved to persistent store
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinates.latitude
            pin.longitude = coordinates.longitude
            try? dataController.viewContext.save()
            
            //set the pin being dropped as the current pin
            self.currentPin = pin
            annotation.associatedPin = pin
            self.pinHasPhotos = true
            
    }

    func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
        let photoAlbumVC = self.storyboard?.instantiateViewController(withIdentifier: "photoAlbumVC") as! PhotoAlbumViewController
        let annotation = didSelect.annotation as! PinAnnotation
        photoAlbumVC.dataController = self.dataController
        photoAlbumVC.photosExist = true
        photoAlbumVC.currentPin = annotation.associatedPin
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
}
