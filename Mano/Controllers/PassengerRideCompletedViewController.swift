//
//  PassengerRideCompletedViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/18/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import Kingfisher

class PassengerRideCompletedViewController: UIViewController {

    
    @IBOutlet weak var driverImage: RoundedImageViewWhite!
    @IBOutlet weak var driverNameLabel: UILabel!
    
    private var ride: Ride!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ride: Ride) {
        self.ride = ride
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        driverNameLabel.text = ride.driverName
        guard let imageURL = URL(string: ride.driveProfileImage) else {return}
        driverImage.kf.setImage(with: imageURL)
    }
    
    @IBAction func addWasPressed(_ sender: Any) {
        
    }
    
    @IBAction func continuePressed(_ sender: Any) {
    }
    

}