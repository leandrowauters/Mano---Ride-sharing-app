//
//  ChooseLocationViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/8/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import GooglePlaces

protocol ChooseLocationDelegate: AnyObject {
    func choseLocation(ride: Ride)
}
class ChooseLocationViewController: UIViewController {

    var dropoffAddress: String!
    var dropoffName: String!
    var dropoffLat: Double!
    var dropoffLon: Double!
    var currentLat: Double!
    var currentLon: Double!
    var ride: Ride!
    weak var delegate: ChooseLocationDelegate!
    
    @IBOutlet weak var locationButton: RoundedButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropoffAddress = DBService.currentManoUser.homeAdress
        dropoffName = ""
        dropoffLon = DBService.currentManoUser.homeLon
        dropoffLat = DBService.currentManoUser.homeLat
    }

    @IBAction func locationButtonPressed(_ sender: Any) {
        MapsHelper.setupAutoCompeteVC(Vc: self)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        DBService.updateToNewRide(pickupAddress: ride.dropoffAddress, pickupLat: currentLat, pickupLon: currentLon, dropoffAddress: dropoffAddress, dropoffName: dropoffName , dropoffLat: dropoffLat, dropoffLon: dropoffLon, rideStatus: RideStatus.changedToReturnPickup.rawValue, ride: ride) { (error, ride) in
            if let error = error {
                self.showAlert(title: "Error updating to new ride", message: error.localizedDescription)
            }
            if let ride = ride {

                self.delegate.choseLocation(ride: ride)
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ride: Ride, currentLat: Double, currentLon: Double, delegate: ChooseLocationDelegate) {
        self.ride = ride
        self.delegate = delegate
        self.currentLat = currentLat
        self.currentLon = currentLon
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChooseLocationViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let dropoffAddress = place.formattedAddress else {
            showAlert(title: "Error finding address", message: nil)
            return}
        if let dropoffName = place.name {
            self.dropoffName = dropoffName
        } else {
            self.dropoffName = ""
        }
        let coordinate = place.coordinate
        self.dropoffAddress = dropoffAddress
        let shorterAddress = MapsHelper.getShortertString(string: dropoffAddress)
        locationButton.setTitle(shorterAddress, for: .normal)
        dropoffLat = coordinate.latitude
        dropoffLon = coordinate.longitude
        dismiss(animated: true, completion: nil)
        
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}
