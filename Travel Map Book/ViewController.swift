//
//  ViewController.swift
//  Travel Map Book
//
//  Created by Kornet Project on 16/08/2017.
//  Copyright © 2017 Kornet Project. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var chosenLatitude : Double = 0
    var chosenLongitude : Double = 0
    
    var transmittedTitle = ""
    var transmittedSubitle = ""
    var transmittedLatitude : Double = 0
    var transmittedLongtitude : Double = 0
    
    var requestCLLocation = CLLocation()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Mapview and location manager attributes
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Create Gesture Recognition
        let recognize = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.chooseLocation(gestureRecognizer:)))
        recognize.minimumPressDuration = 3
        mapView.addGestureRecognizer(recognize)
        
        if transmittedTitle != ""{
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: self.transmittedLatitude, longitude: self.transmittedLongtitude)
            annotation.coordinate = coordinate
            annotation.title = self.transmittedTitle
            annotation.subtitle = self.transmittedSubitle
            self.mapView.addAnnotation(annotation)
            
            self.nameText.text = self.transmittedTitle
            self.commentText.text = self.transmittedSubitle
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reuseID = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = UIColor.red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if transmittedLatitude != 0 {
            if transmittedLongtitude != 0{
                self.requestCLLocation = CLLocation(latitude: transmittedLatitude, longitude: transmittedLongtitude)
            }
        }
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemark = placemarks{
                if placemark.count > 0{
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = self.transmittedTitle
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newlocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        newlocation.setValue(nameText.text, forKey: "title")
        newlocation.setValue(commentText.text, forKey: "subtitle")
        newlocation.setValue(self.chosenLatitude, forKey: "latitude")
        newlocation.setValue(self.chosenLongitude, forKey: "longtitude")
        
        do {
            try context.save()
            print("we managed to save it")
        } catch {
            print ("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"newLocationCreated"), object: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began{
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let chosenCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            self.chosenLatitude = chosenCoordinates.latitude
            self.chosenLongitude = chosenCoordinates.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
    }
}

