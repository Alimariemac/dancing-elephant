//
//  UIView1.swift
//  diveBarv3
//
//  Created by Alicia MacCara on 9/2/19.
//  Copyright © 2019 Alicia MacCara. All rights reserved.
//

import UIKit
import MapKit

class UIView1: UIViewController {
    @IBOutlet var barTitle: UILabel!
    @IBOutlet var barPrice: UILabel!
    @IBOutlet var barInfo: UITextView!
    @IBOutlet var mapView: MKMapView!
    
    let annotation = MKPointAnnotation()
    var lat : Double = 0
    var long : Double = 0
    var randomBar : Bar?
    var regionRadius: CLLocationDistance = 1200
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    var destinationLocation = CLLocation(latitude: 0, longitude: 0)
    
    override func viewDidLoad() {
        //ui setup
        barTitle.text = ""
        barInfo.text = ""
        barPrice.text = ""
        barTitle.isHidden = true
        barInfo.isHidden = true
        barPrice.isHidden = true
        mapView.isHidden = true

        //map setup
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        
            initialLocation = CLLocation(latitude: CLLocationDegrees(self.lat) as! CLLocationDegrees, longitude: CLLocationDegrees(self.long) as! CLLocationDegrees)
        
            if let randomBar = randomBar {
            destinationLocation = CLLocation(latitude: randomBar.coordinate.latitude, longitude: randomBar.coordinate.longitude)
            let distanceInMeters = initialLocation.distance(from: destinationLocation)
            regionRadius = distanceInMeters + 400
            //directions
            let directionRequest = MKDirections.Request()
            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(self.lat), longitude: Double(self.long)), addressDictionary: nil))
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (randomBar.coordinate.latitude), longitude : (randomBar.coordinate.longitude)), addressDictionary: nil))
            directionRequest.transportType = .walking
        }
        
        //set up callout
        
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
  
        //set up UI
        implementUI()
        
        super.viewDidLoad()
    }
    
    
    func implementUI(){
        if let randomBar = randomBar{
            let centerOfMap = CLLocation(latitude: ((initialLocation.coordinate.latitude + destinationLocation.coordinate.latitude)/2), longitude: ((initialLocation.coordinate.longitude + destinationLocation.coordinate.longitude)/2))
            centerMapOnLocation(location: centerOfMap)
            mapView.showsUserLocation = true
        
            annotation.coordinate = randomBar.coordinate
            annotation.title = randomBar.title
            annotation.subtitle = "get directions"

            DispatchQueue.main.async {
                self.mapView.addAnnotation(self.annotation)
                self.barTitle.text = randomBar.title
                self.barTitle.isHidden = false
                self.barInfo.text = randomBar.barDescription
                self.barInfo.isHidden = false
                self.barPrice.text = "\(randomBar.barPrice) • \(randomBar.barRating)/10"
                self.barPrice.isHidden = false
                self.mapView.isHidden = false
                
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        print(regionRadius)
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
extension UIView1 : MKMapViewDelegate {
    class CustomAnnotationView: MKMarkerAnnotationView {
        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            
            canShowCallout = true
            rightCalloutAccessoryView = UIButton(type: .custom)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

}
