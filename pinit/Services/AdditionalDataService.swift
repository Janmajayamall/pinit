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
    var currentLocationGeohashModel: GeohashModel?
    
    var feedbacksCollectionRef: CollectionReference = Firestore.firestore().collection("feedbacks")
    
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
                "content": "New User Feedback",
                "embeds":[[
                    "fileds":[
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
            }
            
        }
        catch{
            
        }
        
    }
    
    init() {
        // subscribe to publishers
        self.subscribeToUserProfileService()
        self.subscribeToGeohashingServicePublishers()
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
    
    func subscribeToGeohashingServicePublishers() {
        Publishers.geohasingServiceDidUpdateGeohashPublisher.sink { (geohashModel) in
            self.currentLocationGeohashModel = geohashModel
        }.store(in: &cancellables)
    }
    
    func subscribeToAdditionalDataServicePublishers() {
        Publishers.additionalDataServiceDidRequestReportUserModelPublisher.sink { (requestModel) in
            
        }.store(in: &cancellables)
        
        Publishers.additionalDataServiceDidRequestFeedbackPublisher.sink { (requestModel) in
            self.addUserFeedback(withRequestModel: requestModel)
        }.store(in: &cancellables)
    }
}
