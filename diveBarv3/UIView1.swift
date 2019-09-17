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
    @IBOutlet var collectionView: UICollectionView!
    
    let annotation = MKPointAnnotation()
    var lat : Double = 0
    var long : Double = 0
    var randomBar : Bar?
    var regionRadius: CLLocationDistance = 1200
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    var destinationLocation = CLLocation(latitude: 0, longitude: 0)
    var initialLocation2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var destinationLocation2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var intitialPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    var destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    var initialItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)))
    var destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)))
    var rangedBody : String = ""

    override func viewDidLoad() {
        // MARK: - ui setup
        barTitle.text = ""
        barInfo.text = ""
        barPrice.text = ""
        barTitle.isHidden = true
        barInfo.isHidden = true
        barPrice.isHidden = true
        mapView.isHidden = true
        mapView.delegate = self

        // MARK: -map setup
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        collectionView.dataSource = self
        
        
            if let randomBar = randomBar {
                
                initialLocation = CLLocation(latitude: CLLocationDegrees(self.lat) , longitude: CLLocationDegrees(self.long) )
                 destinationLocation = CLLocation(latitude: randomBar.coordinate.latitude, longitude: randomBar.coordinate.longitude)
            //set to 2d
                destinationLocation2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(randomBar.coordinate.latitude), longitude: randomBar.coordinate.longitude)
                initialLocation2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.lat), longitude: CLLocationDegrees(self.long))
                //placemarks
                intitialPlacemark = MKPlacemark(coordinate: initialLocation2D)
                destinationPlacemark = MKPlacemark(coordinate: destinationLocation2D)
                
                //items
                initialItem = MKMapItem(placemark: intitialPlacemark)
                destinationItem = MKMapItem(placemark: destinationPlacemark)
                
                //distance for wide radius
                let distanceInMeters = initialLocation.distance(from: destinationLocation)
                regionRadius = distanceInMeters + 400
                
                //truncate text
                print(randomBar.barDescription)
                if(randomBar.barDescription.count > 100){
                rangedBody = String(randomBar.barDescription.prefix(120))
                }
                else {
                    rangedBody = randomBar.barDescription
                }
    }
       
        
        //set up callout....change this -> click on annotation and bring up iOS maps?
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        //set up UI
        implementUI()
        super.viewDidLoad()
        
    }
    
     // MARK: -UI function
    
    func implementUI(){
        if let randomBar = randomBar{
            
            //setting up center of map
            let centerOfMap = CLLocation(latitude: ((initialLocation.coordinate.latitude + destinationLocation.coordinate.latitude)/2), longitude: ((initialLocation.coordinate.longitude + destinationLocation.coordinate.longitude)/2))
                centerMapOnLocation(location: centerOfMap)
                mapView.showsUserLocation = true
            
                //annotation
                annotation.coordinate = randomBar.coordinate
                annotation.title = randomBar.title
                annotation.subtitle = "\(randomBar.barPrice) • \(randomBar.barRating)"
            
                // adding links and styling text
                if let url = URL(string: randomBar.canonicalURL) {
                   let descriptionText = NSMutableAttributedString(string: "\(rangedBody) ... see more", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21)])
                descriptionText.setAttributes([.link: url], range: NSMakeRange(descriptionText.length - 8, 8))
                    barInfo.textContainer.lineFragmentPadding = 0
                    self.barInfo.isUserInteractionEnabled = true
                    self.barInfo.isEditable = false
                    self.barInfo.linkTextAttributes = [
                        .foregroundColor: UIColor.blue,
                        .underlineStyle: NSUnderlineStyle.single.rawValue
                    ]
                    
           //thread 1 change ui
            DispatchQueue.main.async {
                
                self.mapView.addAnnotation(self.annotation)
                self.barTitle.text = randomBar.title
                self.barTitle.isHidden = false
                self.barInfo.attributedText = descriptionText
                self.barInfo.isHidden = false
                self.barPrice.text = "\(randomBar.barPrice) • \(randomBar.barRating)/10"
                self.barPrice.isHidden = false
                self.mapView.isHidden = false
  
                }
            }
        }
    }
    
    // MARK: -centering function
    
    func centerMapOnLocation(location: CLLocation) {
        print(regionRadius)
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

     // MARK: -directions function
    func getDirections(){
        let directionRequest = MKDirections.Request()
        directionRequest.source = initialItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            guard let response = response else {
                if let error = error {
                    print("error : \(error)")
                }
                return
            }
            print(response.routes[0].name)
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 2.0
        return renderer
    }
}


// Mark: - MapView extension
extension UIView1 : MKMapViewDelegate {
    class CustomAnnotationView: MKMarkerAnnotationView {
        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

            canShowCallout = true
            let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            rightButton.setImage(UIImage(named: "compass.png"), for: .normal)
            rightCalloutAccessoryView = rightButton
            
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        getDirections()
    }
}

// Mark: - CollectionView extension

extension UIView1 : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("in extension")
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath) as! ImageCell
        if let randomBar = randomBar {
        cell.imageView.image = UIImage(named: "bar")
        }
        return cell
    }
}

extension UIView1: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item + 1)
    }
}




