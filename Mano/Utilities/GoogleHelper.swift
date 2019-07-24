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
    
    static public func calculateEta(originLat: Double, originLon: Double, destinationLat: Double, destinationLon: Double, completionHandler: @escaping(AppError?,GoogleHelperResults?) -> Void) {
        let departureTime = Int(Date().timeIntervalSince1970)
        let endpointUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originLat),\(originLon)&destination=\(destinationLat),\(destinationLon)&departure_time=\(departureTime)&key=\(GoogleMapsAPI.GoogleMapsAPIKey)"
        print(endpointUrl)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointUrl) { (appError, data) in
            if appError != nil {
                completionHandler(AppError.badURL("Bad URL"), nil)
            }
            if let data = data {
                do{
                    let duration = try JSONDecoder().decode(GoogleHelperResults.self, from: data)
                    print(duration.routes)
                    completionHandler(nil, duration)
                } catch {
                    completionHandler(appError, nil)
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

}

struct Result: Codable {
    let text: String
    let value: Int
}
