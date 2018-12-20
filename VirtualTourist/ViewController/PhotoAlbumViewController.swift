//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Bhavya D J on 01/12/18.
//  Copyright © 2018 Bhavya D J. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapImage: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImageLabel:UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //MARK: Properties
    var dataController: DataController!
    var currentPin: Pin!
    var photosForPin: [Photo] = []
    var photosExist: Bool!
    let itemSpacing: CGFloat = 9.0
    var photoCount: Int = 0
    var placeHoldersNeeded: Bool = true
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noImageLabel.isHidden = true
        self.newCollectionButton.isEnabled = false
        self.activityIndicator.startAnimating()
        //set the region of the map
        let latDelta: Double = 0.01
        let lonDelta: Double = 0.01
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let centerCoordinate = CLLocationCoordinate2D(latitude: currentPin.latitude, longitude: currentPin.longitude)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        DispatchQueue.main.async {
            self.mapImage.setRegion(region, animated: true)
        }
        
        //add the current pin to the mapView
        let pin = PinAnnotation()
        pin.setCoordinate(newCoordinate: centerCoordinate)
        DispatchQueue.main.async {
            self.mapImage.addAnnotation(pin)
        }
        
        //check if photos already exist in the pin or if it is new
        if !photosExist {
            getNewPhotos()
            try? dataController.viewContext.save()
        } else {
            reloadImages()
        }
    }
    
    //pull photos from flickr using the coords from currentPin
     func getNewPhotos() {
        VirtualTouristModel.sharedInstance().getPhotosForLocation(latitude: currentPin.latitude, longitude: currentPin.longitude) {(success, error, data, imageCount, totalPages, currentPage)  in
            if success {
                DispatchQueue.main.async {
                    self.newCollectionButton.isEnabled = true
                    self.photoCount = imageCount
                    if self.photoCount != 0 {
                        self.noImageLabel.isHidden = true
                    } else {
                        self.noImageLabel.isHidden = false
                    }
                }
                
                //Create a photo entity for each data item pulled from Flickr and add a url property to it as imageURL property
                for url in data {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageURL = url
                    self.currentPin.addToPhotos(photo)
                    self.photosForPin.append(photo)
                }
                DispatchQueue.main.async {
                    try? self.dataController.viewContext.save()
                    self.photoCollectionView.reloadData()
                    self.newCollectionButton.isEnabled = true
                }
            }
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: "Default Action"), style: .default))
                alert.message = error!
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //create fetch request
    func fetchPhotos() -> NSFetchRequest<Photo> {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", currentPin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return fetchRequest
    }
    
    //load images that have been previously downloaded
     func reloadImages() {
        DispatchQueue.main.async {
            let photoFetchRequest = self.fetchPhotos() as NSFetchRequest<Photo>
            self.photosForPin = try! self.dataController.viewContext.fetch(photoFetchRequest) as [Photo]
            self.photoCount = self.photosForPin.count
            self.photoCollectionView.reloadData()
            self.newCollectionButton.isEnabled = true
        }
        
    }
    
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        for photo in self.photosForPin {
            dataController.viewContext.delete(photo)
        }
        self.photosForPin = []
        getNewPhotos()
        try? dataController.viewContext.save()
    }
    
    //function for loading images that are stored or that are being downloaded
    private func downloadImage(using cell: PhotoCollectionViewCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.imageData {
            DispatchQueue.main.async {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.isHidden = true
                cell.cellImage.image = UIImage(data: Data(referencing: imageData as NSData))
            }
        } else {
            if let imageUrl = photo.imageURL {
                DispatchQueue.main.async {
                    cell.activityIndicator.isHidden = false
                    cell.activityIndicator.startAnimating()
                }
                do {
                    let imageData = try Data(contentsOf: imageUrl)
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        cell.cellImage.image = image
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.isHidden = true
                    }
                    photo.imageData = imageData
                } catch{
                    print("failed to download image from URL")
                }
            }
        }
    }
    
    // MARK: CollectionView DataSource
    func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.photoCount > 0 {
            DispatchQueue.main.async {
                self.noImageLabel.isHidden = true
            }
            return self.photoCount
        } else {
            DispatchQueue.main.async {
                self.noImageLabel.isHidden = false
            }
            return self.photoCount
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celldentifier = "PhotoCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: celldentifier, for: indexPath) as! PhotoCollectionViewCell
        DispatchQueue.main.async {
            cell.cellImage.image = nil
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }
        
        let photo = self.photosForPin[indexPath.row]
        downloadImage(using: cell, photo: photo, collectionView: collectionView, index: indexPath)
        return cell
    }
    
    func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = self.photosForPin[indexPath.row]
        self.photosForPin.remove(at: indexPath.row)
        dataController.viewContext.delete(photoToDelete)
        self.photoCount -= 1
        DispatchQueue.main.async {
            self.photoCollectionView.deleteItems(at: [indexPath])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((view.frame.width) - (3 * itemSpacing))/3
        let height = width
        
        return CGSize(width: width, height: height)
    }
}
