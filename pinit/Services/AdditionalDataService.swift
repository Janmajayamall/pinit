//
//  AdditionalDataService.swift
//  pinit
//
//  Created by Janmajaya Mall on 8/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Firebase
import Combine
import CoreLocation

class AdditionalDataService {
    var userProfile: ProfileModel?
    var currentLocation: CLLocation?
    
    var feedbacksCollectionRef: CollectionReference = Firestore.firestore().collection("feedbacks")
    var reportedUsersCollectionRef: CollectionReference = Firestore.firestore().collection("reportedUsers")
    
    private var cancellables: Set<AnyCancellable> = []
    
    func addUserFeedback(withRequestModel requestModel: RequestFeedbackModel){
        guard let userProfile = self.userProfile else {return}
       
        do {
            // upload feedback to firebase
            let feedback = FeedbackModel(userId: userProfile.id!, username: userProfile.username, email: userProfile.email, topic: requestModel.title, description: requestModel.description)
            _ = try self.feedbacksCollectionRef.document(feedback.id!).setData(from: feedback)
            
            // call discord webhook url to post the feedback
            guard let webhookUrl = URL(string: "https://discord.com/api/webhooks/763499688972255241/Jh5yY2WtV5bPO1_l_VPqbUrIDPHnsu3laGUeMZvYd3HSSJ013xlfsn6QbuYpUkNiPfjB") else {return}
            // creating discord content
            let jsonData: [String: Any] = [
                "content": "**New User Feedback**",
                "embeds":[[
                    "fields":[
                        [
                            "name":"UserId",
                            "value":feedback.userId,
                            "inline":true
                        ],
                        [
                            "name":"Username",
                            "value":feedback.username,
                            "inline":true
                        ],
                        [
                            "name":"EmailID",
                            "value":feedback.email,
                            "inline":true
                        ],
                        [
                            "name":"Feedback ID",
                            "value":feedback.id!,
                            "inline":false
                        ],
                        [
                            "name":"Feedback Topic",
                            "value":feedback.topic,
                            "inline":false
                        ],
                        [
                            "name":"Feedback Description",
                            "value":feedback.description,
                            "inline":false
                        ]
                    ],
                    "color": "16729344"
                    ]]
            ]
            
            // create & call post endpoint
            var networkRequest = URLRequest(url: webhookUrl)
            networkRequest.httpMethod = "POST"
            networkRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            networkRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            networkRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonData, options: [])
            URLSession.shared.dataTask(with: networkRequest) {data, response, error in
                if let error = error {
                    print("Webhook request for user feedback failed with error \(error.localizedDescription)")
                }
            }.resume()
            
        }
        catch{
        
        }
        
    }
    
    func addReportedUser(withRequestModel requestModel: RequestReportUserModel){
        guard let userProfile = self.userProfile, let currentLocation = self.currentLocation else {return}
        
        let geopoint = GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        do {
            // upload the report to firebase
            let reportUser = ReportUserModel(userId: userProfile.id!, username: userProfile.username, email: userProfile.email, reportedUsername: requestModel.reportedUsername, reason: requestModel.reason, reportLocation: geopoint)
            _ = try self.reportedUsersCollectionRef.document(reportUser.id!).setData(from: reportUser)
            
            // call discord webhook url to post about new reported user
            guard let webhookUrl = URL(string: "https://discord.com/api/webhooks/763569848264818738/Gmk1-c16keVpyYDjWwVjQh2SnaVdUC51T9-D2JOGQ5DuF-qSdxEASMOkQKLn0i45_Hd0") else {return}
            
            //creating discord content
            let jsonData: [String: Any] = [
                "content": "**New User Reported for offensive content**",
                "embeds":[[
                    "fields":[
                        [
                            "name":"Reported by UserId",
                            "value":reportUser.userId,
                            "inline":true
                        ],
                        [
                            "name":"Reported by Username",
                            "value":reportUser.username,
                            "inline":true
                        ],
                        [
                            "name":"Reported by EmailID",
                            "value":reportUser.email,
                            "inline":true
                        ],
                        [
                            "name":"Reported at location",
                            "value":"*lat, long:* \(reportUser.reportLocation.latitude), \(reportUser.reportLocation.longitude)",
                            "inline":true
                        ],
                        [
                            "name":"Report ID",
                            "value":reportUser.id!,
                            "inline":false
                        ],
                        [
                            "name":"Reported Username",
                            "value":reportUser.reportedUsername,
                            "inline":false
                        ],
                        [
                            "name":"Reported Reason",
                            "value":reportUser.reason,
                            "inline":false
                        ]
                    ],
                    "color": "16729344"
                    ]]
            ]
            
            // create & call post endpoint
            var networkRequest = URLRequest(url: webhookUrl)
            networkRequest.httpMethod = "POST"
            networkRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            networkRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            networkRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonData, options: [])
            URLSession.shared.dataTask(with: networkRequest) {data, response, error in
                if let error = error {
                    print("Webhook request for report user failed with error \(error.localizedDescription)")
                }
            }.resume()
            
        }catch{
            
        }
    }
    
    init() {
        // subscribe to publishers
        self.subscribeToUserProfileService()
        self.subscribeToEstimatedUserLocationService()
        self.subscribeToAdditionalDataServicePublishers()
    }
}

// extension for subscribing to publishers
extension AdditionalDataService {
    func subscribeToUserProfileService() {
        Publishers.userProfileServiceDidUpdateUserProfilePublisher.sink { (userProfile) in
            self.userProfile = userProfile
        }.store(in: &cancellables)
    }
    
    func subscribeToEstimatedUserLocationService() {
        Publishers.estimatedUserLocationServiceDidUpdateLocation.sink { (location) in
            self.currentLocation = location
        }.store(in: &cancellables)
    }
    
    func subscribeToAdditionalDataServicePublishers() {
        Publishers.additionalDataServiceDidRequestReportUserModelPublisher.sink { (requestModel) in
            self.addReportedUser(withRequestModel: requestModel)
        }.store(in: &cancellables)
        
        Publishers.additionalDataServiceDidRequestFeedbackPublisher.sink { (requestModel) in
            self.addUserFeedback(withRequestModel: requestModel)
        }.store(in: &cancellables)
    }
}
