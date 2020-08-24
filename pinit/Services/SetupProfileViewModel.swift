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
//        notify user profile service for creating the profile
        print("here we are")
    }
}

extension SetupProfileViewModel {
    func subscribeToUserProfileServicePublishers(){
        Publishers.userProfileServiceDidSetupProfileImagePublisher.sink { (image) in
            self.profileImage = image
        }.store(in: &cancellables)
    }
}
