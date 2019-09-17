//
//  NetworkController.swift
//  diveBarv3
//
//  Created by Alicia MacCara on 9/1/19.
//  Copyright © 2019 Alicia MacCara. All rights reserved.
//

import Foundation
import MapKit

class NetworkController{
    let client_id = Secrets().clientId
    let client_secret = Secrets().clientSecret
    let start = "https://api.foursquare.com/v2/"
    var randomBar = Bar(coordinate:  CLLocationCoordinate2D(latitude: 0, longitude: 0),barRating: "0", barPrice: "1", title: "Empty Bar", barDescription: "No description here", barImages: ["bar"], canonicalURL: "https://foursquare.com/city-guide")
    var agreeCount : Int = 0
    func getAPI(middle: String , completion:@escaping ([String:Any])->()){
        print(middle)
        if let url = URL(string: "\(start)\(middle)&client_id=\(client_id)&client_secret=\(client_secret)&v=20190829"){
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: url)
            {
                
                data, response, error in
                guard error == nil else
                {
                    print("error: \(error!)")
                    return
                }
                guard let content = data else
                {
                    print("no data")
                    return
                }
                guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String:Any] else
                {
                    print("Not Containing JSON")
                    return
                }
                guard let dictionary = json["response"] as? [String:Any]
                    else{
                        print("no dictionary of venues")
                        return
                }
            
                completion(dictionary)
            }
          task.resume()
        }
    }
    
    func getRandomBar(dictionary:[String:Any], completion:@escaping (String)->()){
        var bars = [String]()
        
        guard let venues = dictionary["venues"] as? [[String:Any]]
            else {
                print("no venues")
                return
            }
        for var v in venues{
            guard let barId = v["id"] as? String else
            {
                return
            }
            bars.append(barId)
        }
        guard let randomElement = bars.randomElement()else
        {
            return
        }
        completion("venues/\(randomElement)?")
    }
    
    
    func getVenueDetails(dictionary:[String:Any], completion:@escaping (Bar)->()){
        var barPrice = "1"
        var description = "No one has said anything about this bar! Risk it and be the first one!"
        var rate = "0"
        guard let venueObject = dictionary["venue"] as? [String:Any],
            let barName = venueObject["name"] as? String,
            let canonicalURL = venueObject["canonicalUrl"] as? String,
            let location = venueObject["location"] as? [String:Any],
            let lat = location["lat"] as? Double,
            let long = location["lng"] as? Double
            else
        {
                return
                
        }
        
        //rating
        if let rating = venueObject["rating"] as? Double{
            rate = String(rating)
        }
        else {
            rate = "?"
        }
        //price
        if let price = venueObject["price"] as? [String:Any]
        {
            if let tier = price["tier"] as? Int
            {
                switch tier{
                case 1:
                    barPrice = "$"
                case 2:
                    barPrice = "$$"
                case 3:
                    barPrice = "$$$"
                case 4:
                    barPrice = "$$$$"
                default:
                    barPrice = "$$$$"
                }
               
            }
        }
        guard let photos = venueObject["photos"] as? [String:Any],
            let photoGroups = photos["groups"] as? [[String:Any]]
            else{
                print("There is an error")
                return
        }
        if let venuePhotos = photoGroups[1] as? [String:Any]{
            let photoItems = venuePhotos["items"] as? [[String:Any]]
            print(photoItems)
        }
        else{
            print("index out of range?")
        }
        
//            let venuePhotos = photoGroups[1] as? [String:Any],
//            let photoItems = venuePhotos["items"] as? [String:Any]
//            else{
//                print("there is an error")
//                return
        
        
        
        guard let tips = venueObject["tips"] as? [String:Any],
            let groups = tips["groups"] as? [[String:Any]],
            let items = groups[0]["items"] as? [[String:Any]]
            else {
                print("no tips")
                return
        }
        for item in items {
            if let agreeCount = item["agreeCount"] as? Int{
                if agreeCount > self.agreeCount {
                    self.agreeCount = agreeCount
                    if let des = item["text"] as? String {
                        description = des
                        print(des)
                    }
                    else{
                        return
                        
                    }
                }
            }
            else{
                description = "No one has said anything about this bar! Risk it and be the first one!"
            }
        }
        
        self.randomBar = Bar(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), barRating: String(rate),barPrice: barPrice, title: barName, barDescription: description, barImages: ["abc"], canonicalURL: canonicalURL)
        print(self.randomBar)
        completion(self.randomBar)
    }
    
    
}

