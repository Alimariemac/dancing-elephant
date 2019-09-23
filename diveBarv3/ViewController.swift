//
//  ViewController.swift
//  diveBarv3
//
//  Created by Alicia MacCara on 9/1/19.
//  Copyright © 2019 Alicia MacCara. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var lat : Double = 0;
    var long : Double = 0;
    var flag : Bool = true
    var randomBar : Bar?
   
    
    override func viewDidLoad() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if CLLocationManager.locationServicesEnabled() {
            if flag {
                if let location = locations.first{
                    lat = location.coordinate.latitude
                    long = location.coordinate.longitude
                }
                print(lat,long)
                flag = false
                doAllBarFinder{
                    
                }
            }
            else{
                return()
            }
        }
        else{
            showLocationAlert()
        }
    }
    
    func showLocationAlert() {
        let alert = UIAlertController(title: "Location Disabled", message: "Please enable location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func doAllBarFinder(completion:@escaping () -> ()){
        let nc = NetworkController()
        nc.getAPI(middle: "venues/search?ll=\(lat),\(long)&categoryId=4bf58dd8d48988d118941735&radius=1500") { (dictionary) in
            nc.getRandomBar(dictionary: dictionary, completion: { (middle) in
                nc.getAPI(middle: middle, completion: { (dictionary) in
                    nc.getVenuePhotos(dictionary: dictionary, completion: { (middle) in
                        nc.getAPI(middle: middle, completion: { (dictionary) in
                            nc.getVenueDetails(dictionary: dictionary, completion: { (Bar) in
                                self.randomBar = Bar
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "barDetails", sender:self)
                                }
                            })
                        })
                    })
                })
            })
        }
    }

//    func doAllBarFinder(completion:@escaping () -> ()){
//        let nc = NetworkController()
//        nc.getAPI(middle: "venues/search?ll=\(lat),\(long)&categoryId=4bf58dd8d48988d118941735&radius=1500") { (dictionary) in
//            nc.getRandomBar(dictionary: dictionary, completion: { (middle) in
//                nc.getAPI(middle: middle, completion: { (dictionary) in
//                    nc.getVenueDetails(dictionary: dictionary, completion: { (Bar) in
//                        self.randomBar = Bar
//                        DispatchQueue.main.async {
//                            self.performSegue(withIdentifier: "barDetails", sender:self)
//                        }
//                    })
//                })
//            })
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "barDetails" {
            let vc = segue.destination as! UIView1
            vc.lat = self.lat
            vc.long = self.long
            vc.randomBar = randomBar
        }
    }

    
}
