//
//  WaitingForRequestViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/7/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class WaitingForRequestViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var passengerView: UIView!
    @IBOutlet weak var pulsingView: CircularViewNoBorder!
    @IBOutlet weak var mapImageView: UIImageView!
    
    private var userLocation = CLLocation()
    private var locationManager = CLLocationManager()
    var thirtySecondTimer = 0
    var ride: Ride!
    var graphics = GraphicsClient()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoreLocation()
        setup()
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            thirtyMinTimer()
            calculateCurrentMilesToPickup()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            thirtyMinTimer()
            calculateCurrentMilesToPickup()
            graphics.pulsatingNoReverse(view: pulsingView)
        } else {
            DBService.listenForDistanceDurationUpdates(ride: ride) { (error, ride) in
                if let error = error {
                    self.showAlert(title: "Error listening", message: error.localizedDescription)
                }
                if let ride = ride {
                    self.distanceLabel.text = "Distance: \n \(MainTimer.timeString(time: TimeInterval(ride.durtation))) away"
                }
            }
        }
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ride: Ride) {
        self.ride = ride
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        changeToOnWaitingRequest()
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            locationManager.delegate = self
            titleLabel.text = "Waiting For  Request "
            messageLabel.text = "PLEASE KEEP APP OPEN TO SHARE LOCATION"
        } else {
            messageLabel.text = "PLEASE GIVE DRIVER ENOUGH TIME BEFORE YOUR REQUEST"
            titleLabel.text = "Request Ride Back Home"
            passengerView.isHidden = false
            driverView.isHidden = true
            
        }
    }
    
    private func setupCoreLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    
    private func changeToOnWaitingRequest() {
        DBService.updateRideStatus(ride: ride, status: RideStatus.onWaitingToRequest.rawValue) { (error) in
            if let error = error {
                self.showAlert(title: "Error updating to on pickup", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func thirtyMinTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.thirtySecondTimer == 30 {
                self.calculateCurrentMilesToPickup()
                self.thirtySecondTimer = 0
            } else {
                self.thirtySecondTimer += 1
            }
        }
    }
    
    func calculateCurrentMilesToPickup() {
        GoogleHelper.calculateMilesAndTimeToDestination(pickup: false, ride: ride, userLocation: userLocation) { (miles, time, milesInt, timeInt) in
            self.distanceLabel.text = "Distance: \n \(time) Away"
            DBService.updateRideDurationDistance(ride: self.ride, distance: milesInt, duration: timeInt, completion: { (error) in
                if let error = error {
                    self.showAlert(title: "Error updating duration", message: error.localizedDescription)
                }
            })
        }
    }
    
    private func sendMessage(number: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
//            controller.body = message
            controller.recipients = [number]
            controller.messageComposeDelegate = self
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func requestRidePressed(_ sender: Any) {
        
    }
    @IBAction func phonePressed(_ sender: Any) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            guard let number = URL(string: "tel://" + ride.passangerCell) else {
                self.showAlert(title: "Wrong number", message: nil)
                return }
            UIApplication.shared.open(number)
        } else {
            guard let number = URL(string: "tel://" + ride.driverCell) else {
                self.showAlert(title: "Wrong number", message: nil)
                return }
            UIApplication.shared.open(number)
        }
    }
    @IBAction func messagePressed(_ sender: Any) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue{
            sendMessage(number: ride.passangerCell)
        } else {
            sendMessage(number: ride.driverCell)
        }
        
    }
    
    


}

extension WaitingForRequestViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        //        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        userLocation = currentLocation
    }
}

extension WaitingForRequestViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            dismiss(animated: true)
        case .sent:
            dismiss(animated: true)
            showAlert(title: "Message sent", message: nil)
        case .failed:
            dismiss(animated: true)
            showAlert(title: "Message failed to send", message: nil)
        default:
            showAlert(title: "Error sending message", message: "Error unknown")
        }
    }
    
    
}