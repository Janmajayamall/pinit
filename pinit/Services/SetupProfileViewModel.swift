//
//  SetupProfileViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class SetupProfileViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var profileImage: UIImage = UIImage(imageLiteralResourceName: "ProfileImage")
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.subscribeToUserProfileServicePublishers()
    }

    func setupProfile(){
        // creating request for setting up profile for user
        let requestModel = RequestSetupUserProfileModel(username: self.username, profileImage: self.profileImage)
        
        self.postNotification(for: .userProfileServiceDidRequestSetupUserProfile, withObject: requestModel)
    }
    
    func postNotification(for notificationType: Notification.Name, withObject object: Any){
        NotificationCenter.default.post(name: notificationType, object: object)
    }
}

extension SetupProfileViewModel {
    func subscribeToUserProfileServicePublishers(){
        Publishers.userProfileServiceDidSetupProfileImagePublisher.sink { (image) in
            self.profileImage = image
        }.store(in: &cancellables)
    }
}
