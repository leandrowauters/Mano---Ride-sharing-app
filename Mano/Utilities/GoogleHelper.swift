//
//  GoogleHelper.swift
//  Mano
//
//  Created by Leandro Wauters on 7/22/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import GooglePlaces


struct GoogleHelper {
    static public func setupAutoCompeteVC(Vc: UIViewController) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = Vc as? GMSAutocompleteViewControllerDelegate
        let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))
        if let fields = fields {
            autocompleteController.placeFields = fields
            
        }
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        
        autocompleteController.primaryTextHighlightColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        autocompleteController.primaryTextColor = #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1)
        autocompleteController.secondaryTextColor = #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1)
        autocompleteController.tableCellSeparatorColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        Vc.present(autocompleteController, animated: true, completion: nil)
    }
    
    static public func calculateEta(originLat: Double, originLon: Double, destinationLat: Double, destinationLon: Double, completionHandler: @escaping(AppError?, String? , Int?) -> Void) {
        let departureTime = Int(Date().timeIntervalSince1970)
        let endpointUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originLat),\(originLon)&destination=\(destinationLat),\(destinationLon)&departure_time=\(departureTime)&key=\(GoogleMapsAPI.GoogleMapsAPIKey)"
        print(endpointUrl)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointUrl) { (appError, data) in
            if appError != nil {
                completionHandler(AppError.badURL("Bad URL"), nil, nil)
            }
            if let data = data {
                do{
                    let result = try JSONDecoder().decode(GoogleHelperResults.self, from: data)
                        let etaText = result.routes.first?.legs.first?.duration.text
                    let etaInt = result.routes.first?.legs.first?.duration.value
                    completionHandler(nil, etaText, etaInt)
                } catch {
                    completionHandler(appError, nil, nil)
                }
            }
        }
    }
    
    static public func calculateDistanceToLocation(originLat: Double, originLon: Double, destinationLat: Double, destinationLon: Double, completionHandler: @escaping(AppError?, String? , Int?) -> Void) {
        let endpointUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originLat),\(originLon)&destination=\(destinationLat),\(destinationLon)&key=\(GoogleMapsAPI.GoogleMapsAPIKey)"
        print(endpointUrl)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointUrl) { (appError, data) in
            if appError != nil {
                completionHandler(AppError.badURL("Bad URL"), nil, nil)
            }
            if let data = data {
                do{
                    let result = try JSONDecoder().decode(GoogleHelperResults.self, from: data)
                   let estimatedDistanceInText = result.routes.first?.legs.first?.distance.text
                    let estimatedDistanceInInt = result.routes.first?.legs.first?.distance.value
                    completionHandler(nil, estimatedDistanceInText, estimatedDistanceInInt)
                    
                } catch {
                    completionHandler(appError, nil, nil)
                }
            }
        }
    }
}

struct GoogleHelperResults: Codable {
    let routes: [Legs]
    enum CodingKeys : String, CodingKey {
        case routes = "routes"
    }
}
struct Legs: Codable {
    let legs: [Distance]
    enum CodingKeys : String, CodingKey {
        case legs = "legs"
    }
}


struct Distance: Codable {
    let distance: Result
    let duration: Result
}

struct Result: Codable {
    let text: String
    let value: Int
}
