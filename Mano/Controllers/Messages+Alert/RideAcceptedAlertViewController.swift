//
//  RideAcceptedAlertViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/23/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import EventKit

class RideAcceptedAlertViewController: UIViewController {

    var ride: Ride!
    
    @IBOutlet weak var subtitle1: UILabel!
    
    @IBOutlet weak var subtitle2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            subtitle1.text = ride.appointmentDate
            subtitle2.text = "Please contact \(ride.passanger) for more details"
        } else {
            subtitle1.text = ride.appointmentDate
            subtitle2.text = ride.dropoffAddress
        }
    }
    @IBAction func addToCalendarPressed(_ sender: Any) {
        EventKitHelper.shared.addToCalendar(ride: ride) { (error, calendar)  in
            if let error = error {
                self.showAlert(title: "Error adding to calendar", message: error.errorMessage())
                self.dismiss(animated: true)
            }
            if let calendar = calendar {
                self.showAlert(title: "Added!", message: "Calendar: \(calendar)")
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Passenger.rawValue {
            DBService.updateRideToSeen(ride: ride) { (error) in
                if let error = error {
                    self.showAlert(title: "Error updating ride", message: error.localizedDescription)
                }
            }
        }
        dismiss(animated: true)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ride: Ride) {
        self.ride = ride
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
