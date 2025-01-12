//
//  MyLocation.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

class MyLocation: Codable {
    var userId: String
    var locationName: String
    var address: String
    var locationId: String
    
    init(userId: String, locationName: String, address: String, locationId: String) {
        self.userId = userId
        self.locationName = locationName
        self.address = address
        self.locationId = locationId
    }
    
    init(dict:[String:Any]) {
        self.locationName = dict[MyLocationsCollectionKeys.locationNameKey] as? String ??  ""
        self.userId = dict[MyLocationsCollectionKeys.locationAddress] as? String ?? ""
        self.address = dict[MyLocationsCollectionKeys.locationAddress] as?
        String ?? ""
        self.locationId = dict[MyLocationsCollectionKeys.locationIdKey] as? String ?? ""
    }
}
