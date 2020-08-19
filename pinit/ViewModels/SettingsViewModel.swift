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
    
    //services
    private var authenticationService = AuthenticationService()
    @Published var userProfileService = UserProfileService()
    @Published var screenManagementService = ScreenManagementService()
    private var locationService = LocationService()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        
        // for subscribing to objectWillChange publisher of userProfileService that publishes before any of its published property changes value. Calling objectWillChange of self object for notifying self's subscribers that object has changed
        self.userProfileService.objectWillChange.sink { (_) in
            self.objectWillChange.send()
        }.store(in: &cancellables)
        
        // subscribing to publishers from userProfileService using assign.
        // assign allows us to subscribe & assign the value received to property within object using keyPath syntax
        self.userProfileService.$user.assign(to: \.user, on: self).store(in: &cancellables)
        self.userProfileService.$userProfile.assign(to: \.userProfile, on: self).store(in: &cancellables)
        self.userProfileService.$userProfileImage.assign(to: \.userProfileImage, on: self).store(in: &cancellables)
        
        // for susbscribing to objectWillChange publisher of screenManagement view modal
        self.screenManagementService.objectWillChange.sink(receiveValue: { value in
            print(value)
            self.objectWillChange.send()
        }).store(in: &cancellables)
        
        
        Publishers.locationServiceDidUpdateLocationPublisher.sink { (location) in
            self.currentLocation = location
        }.store(in: &cancellables)
    }
    
    func isUserAuthenticated() -> Bool {
        return self.user != nil
    }
}
