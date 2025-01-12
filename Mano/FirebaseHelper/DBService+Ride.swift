//
//  DBService+Ride.swift
//  Mano
//
//  Created by Leandro Wauters on 7/22/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import FirebaseFirestore
extension DBService {
    
    static public func createARide(date: String, passangerId: String, passangerName: String, pickupAddress: String, dropoffAddress: String, dropoffName: String?, pickupLat: Double, pickupLon: Double, dropoffLat: Double, dropoffLon: Double, dateRequested: String, passangerCell: String, completion: @escaping(Error?)-> Void) {
       let ref =  DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document()
        firestoreDB.collection(RideCollectionKeys.collectionKey).document(ref.documentID).setData([RideCollectionKeys.appoinmentDateKey : date,
                                                                                                   RideCollectionKeys.passangerId : passangerId,
                                                                                                   RideCollectionKeys.rideIdKey : ref.documentID,
                                                                                                   RideCollectionKeys.passangerName : passangerName,
                                                                                                   RideCollectionKeys.pickupAddressKey : pickupAddress, RideCollectionKeys.dropoffAddressKey : dropoffAddress, RideCollectionKeys.pickupLatKey : pickupLat, RideCollectionKeys.pickupLonKey : pickupLon, RideCollectionKeys.dropoffLonKey :dropoffLon, RideCollectionKeys.dropoffLatKey : dropoffLat, RideCollectionKeys.dateRequestedKey : dateRequested, RideCollectionKeys.passangerCellKey : passangerCell,
            RideCollectionKeys.dropoffNameKey : dropoffName ?? "Drop-off name unavailable",
            RideCollectionKeys.rideStatusKey : RideStatus.rideRequested.rawValue
                                                                
        ]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func fetchAllRides(completion: @escaping(Error?, [Ride]?) -> Void) {
        let query = firestoreDB.collection(RideCollectionKeys.collectionKey)
        query.addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            }
            if let snapshot = snapshot {
                var rides = [Ride]()
                for document in snapshot.documents {
                    let ride = Ride.init(dict: document.data())
                    if ride.appointmentDate.stringToDate().dateExpired() && (ride.rideStatus != RideStatus.rideCancelled.rawValue || ride.rideStatus != RideStatus.rideIsOver.rawValue || ride.rideStatus != RideStatus.rideRequested.rawValue){
                        deleteRide(ride: ride, completion: { (error) in
                            if let error = error {
                                completion(error, nil)
                            }
                        })
                    } else {
                        rides.append(ride)
                    }
                    
                }
                completion(nil, rides.filter{$0.rideStatus == RideStatus.rideRequested.rawValue })
            }
        }
    }
    
    static public func fetchUserRides(typeOfUser: String, completion: @escaping(Error?, [Ride]?) -> Void) -> ListenerRegistration {
        var key = String()
        if typeOfUser == TypeOfUser.Driver.rawValue {
            key = RideCollectionKeys.driverIdKey
        } else {
           key = RideCollectionKeys.passangerId
        }
        return DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(key, isEqualTo: currentManoUser.userId).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let rides = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, rides)
            }
        }
    }
    
    static public func deleteRide(ride: Ride, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).delete { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func updateRideToAccepted(ride: Ride, completion: @escaping (Error?) -> Void) {
       let currentUser = DBService.currentManoUser!
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.rideStatusKey : RideStatus.rideAccepted.rawValue,
                                                                                                             RideCollectionKeys.acceptenceWasSeenKey : false,
                                                                                                             RideCollectionKeys.driverNameKey : currentUser.fullName, RideCollectionKeys.driverProfileImageKey : currentUser.profileImage!,RideCollectionKeys.driverMakerModelKey : currentUser.carMakerModel!, RideCollectionKeys.licencePlateKey : currentUser.licencePlate!, RideCollectionKeys.carPictureKey : currentUser.carPicture!, RideCollectionKeys.driverCellKey : currentUser.cellPhone!,
                                                                                                             RideCollectionKeys.driverIdKey: currentUser.userId]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    static public func updateRideToSeen(ride: Ride, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.acceptenceWasSeenKey : true]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
//    static func fetchAcceptedRides(completion: @escaping(Error?, [Ride]?) -> Void) -> ListenerRegistration {
//        return DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideStatusKey, isEqualTo: RideStatus.rideAccepted.rawValue ).whereField(RideCollectionKeys.driverIdKey, isEqualTo: currentManoUser.userId).addSnapshotListener { (snapshot, error) in
//            if let error = error {
//                completion(error,nil)
//            }
//            if let snapshot = snapshot {
//                let ridesAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
//                completion(nil, ridesAccepted)
//            }
//        }
//    }
    
    static func listenForRideAcceptence(passangerId: String, completion: @escaping(Error?, Ride?) -> Void) ->ListenerRegistration {
        return DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideStatusKey, isEqualTo: RideStatus.rideAccepted.rawValue).whereField(RideCollectionKeys.passangerId, isEqualTo: passangerId).whereField(RideCollectionKeys.acceptenceWasSeenKey, isEqualTo: false).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, rideAccepted.first)
            }
        }
    }
    
    static public func updateDriverOntItsWay(ride: Ride, originLat: Double, originLon: Double,  completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.inProgressKey : true, RideCollectionKeys.originLatKey : originLat, RideCollectionKeys.originLonKey : originLon, RideCollectionKeys.passangerKnowsDriverOnItsWayKey : false, RideCollectionKeys.rideStatusKey : RideStatus.changedToPickup.rawValue]
                                                                                                        ) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    

    static public func updateRideStatus(ride: Ride, status: String, completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.rideStatusKey : status]) { (error) in
            if let error = error {
                completion(error, nil)
            } else {
                fetchForRide(ride: ride, completion: { (error, ride) in
                    if let error = error {
                        completion(error, nil)
                    }
                    
                    if let ride = ride {
                        completion(nil , ride)
                    }
                })
            }
        }
    }
    static public func listenForRideStatus(ride: Ride, status: String, completion: @escaping(Error?, Ride?) -> Void) -> ListenerRegistration{
        return  DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).whereField(RideCollectionKeys.rideStatusKey, isEqualTo: status).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            }
            if let snapshot = snapshot{
                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, rideAccepted.first)
            }
            
        }
        
    }
    
    

    static public func updatePassangerKnowsDriverOnItsWay(ride: Ride, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.passangerKnowsDriverOnItsWayKey : true]) { (error) in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    static public func updateRideDurationDistance(ride: Ride, distance: Double, duration: Double, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.durationKey : duration, RideCollectionKeys.distanceKey : distance]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func listenForDriverOnItsWay(completion: @escaping(Error?, Ride?) -> Void) -> ListenerRegistration {
         return DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.passangerId, isEqualTo: DBService.currentManoUser.userId).whereField(RideCollectionKeys.inProgressKey, isEqualTo: true).whereField(RideCollectionKeys.passangerKnowsDriverOnItsWayKey, isEqualTo: false).whereField(RideCollectionKeys.rideStatusKey, isEqualTo: RideStatus.changedToPickup.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let driverOnItsWay = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, driverOnItsWay.first)
            }
        }
    }
    
    static public func getRideStatusInProgressDriver(completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.driverIdKey, isEqualTo: DBService.currentManoUser.userId).whereField(RideCollectionKeys.inProgressKey, isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let ride = snapshot.documents.map{Ride.init(dict: $0.data())}.first
                completion(nil, ride)
            }
        }
    }
    
    static public func getRideStatusInProgressPassenger(completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.passangerId, isEqualTo: DBService.currentManoUser.userId).whereField(RideCollectionKeys.inProgressKey, isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let ride = snapshot.documents.map{Ride.init(dict: $0.data())}.first
                completion(nil, ride)
            }
        }
    }
    
    static public func updateTotalMiles(ride: Ride, miles: Double, completion: @escaping(Error?) -> Void) {
        
        firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(error)
            }
            if let snapshot = snapshot {
                let ride = snapshot.documents.map{Ride.init(dict: $0.data())}.first
                if let ride = ride { firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.totalMilesKey : ride.totalMiles + miles]) { (error) in
                        if let error = error {
                        completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    static public func listenForDistanceDurationUpdates(ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let driverOnItsWay = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, driverOnItsWay.first)
            }
        })
    }
    
    static public func updateToNewRide(pickupAddress: String, pickupLat: Double, pickupLon: Double, dropoffAddress: String, dropoffName: String, dropoffLat: Double, dropoffLon: Double, rideStatus: String, ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
        firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.pickupAddressKey : pickupAddress, RideCollectionKeys.pickupLatKey : pickupLat, RideCollectionKeys.pickupLonKey : pickupLon, RideCollectionKeys.dropoffAddressKey : dropoffAddress, RideCollectionKeys.dropoffLonKey : dropoffLon, RideCollectionKeys.dropoffLatKey : dropoffLat,
                                                                            RideCollectionKeys.rideStatusKey : rideStatus,
                                                                            RideCollectionKeys.dropoffNameKey : dropoffName]) { (error) in
            if let error = error {
                completion(error, nil)
            } else {
                fetchForRide(ride: ride, completion: { (error, ride) in
                    if let error = error {
                        completion(error, nil)
                    }
                    if let ride = ride {
                        completion(nil, ride)
                    }
                })
                
            }
        }
    }
    
    static func fetchForRide(ride: Ride, completion: @escaping(Error? , Ride?) -> Void) {
        firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).getDocuments { (snapshot, error) in
            if let snapshot = snapshot?.documents.first {
                let ride = Ride.init(dict: snapshot.data())
                completion(nil, ride)
            }
            
            if let error = error {
                completion(error, nil)
            }
        }
        
    }
}

