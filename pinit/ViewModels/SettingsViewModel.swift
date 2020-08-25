//
//  SettingsViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import CoreLocation

class SettingsViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var userProfile: ProfileModel?
    @Published var userProfileImage: UIImage?
    var currentLocation: CLLocation?
    
    // services
    private var authenticationService = AuthenticationService()
    @Published var userProfileService = UserProfileService()
    @Published var screenManagementService = ScreenManagementService()
    private var locationService = LocationService()
    private var uploadPostService = UploadPostService()
    
    // view models
    @Published var setupProfileViewModel = SetupProfileViewModel()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        // setup subscribers
        self.setupSubscribers()
        
        // setup services
        self.uploadPostService.setupService()
        self.userProfileService.setupService()
        self.locationService.setupService()
        self.authenticationService.setupService()
    }
    
    func isUserAuthenticated() -> Bool {
        return self.user != nil
    }

}

// for subscriptions
extension SettingsViewModel {
    func subscribeToUserProfileServicePublishers() {
        self.userProfileService.objectWillChange.sink { (_) in
            self.objectWillChange.send()
        }.store(in: &cancellables)
        
        self.userProfileService.$user.assign(to: \.user, on: self).store(in: &cancellables)
        
        self.userProfileService.$userProfile.assign(to: \.userProfile, on: self).store(in: &cancellables)
        
        self.userProfileService.$userProfileImage.assign(to: \.userProfileImage, on: self).store(in: &cancellables)
    }
    
    func subscribeToScreenManagementServicePublishers() {
        self.screenManagementService.objectWillChange.sink(receiveValue: { value in
            print(value)
            self.objectWillChange.send()
        }).store(in: &cancellables)
    }
    
    func subscribeToLocationServicePublishers() {
        Publishers.locationServiceDidUpdateLocationPublisher.sink { (location) in
            self.currentLocation = location
        }.store(in: &cancellables)
    }
    
    func subscribeToSetupProfileViewModelPublishers(){
        self.setupProfileViewModel.objectWillChange.sink { (_) in
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    func setupSubscribers() {
        self.subscribeToLocationServicePublishers()
        self.subscribeToUserProfileServicePublishers()
        self.subscribeToScreenManagementServicePublishers()
    }
}


