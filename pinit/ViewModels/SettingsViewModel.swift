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
    
    // services
    private var authenticationService = AuthenticationService()
    @Published var userProfileService = UserProfileService()
    @Published var screenManagementService = ScreenManagementService()
    private var locationService = LocationService()
    private var uploadPostService = UploadPostService()
    private var retrievePostService = RetrievePostService()
    private var geohasingService = GeohashingService()
    
    // view models
    @Published var setupProfileViewModel = SetupProfileViewModel()
    @Published var editingViewModel: EditingViewModel?
    @Published var editingVideoViewModel: EditingVideoViewModel?
    
    
    // all posts
    @Published var allPosts: Dictionary<String, PostModel> = [:]
    
    var appArScnView: AppArScnView = AppArScnView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        // setup subscribers
        self.setupSubscribers()
        
        // setup services
        self.uploadPostService.setupService()
        self.userProfileService.setupService()
        self.retrievePostService.setupService()
        self.geohasingService.setupService()
        self.locationService.setupService()
        self.authenticationService.setupService()
    }
    
    func isUserAuthenticated() -> Bool {
        return self.user != nil
    }
    
    func signOut() {
        // logging out from firebase auth
        self.authenticationService.signOut()
        
        // stopping user profile service
        self.userProfileService.stopServiceForCurrentUser()
        
        // resetting user profile in upload service
        self.uploadPostService.resetCurrentUserProfile()
        
        // resetting the screens
        self.screenManagementService.mainScreenService.resetScreen()
    }
    
    func setupEditingViewModel(withUIImage image: UIImage) {
        // setting up editing view model
        self.editingViewModel = EditingViewModel(selectedImage: image)
        
        // switching to editCaptureImage
        self.screenManagementService.mainScreenService.captureImageViewScreenService.switchTo(screenType: .editCaptureImage)
    }
    
    func setupEditingVideoViewModel(withVideoFilePathUrl fileUrl: URL){
        // setting up editing video view model
        self.editingVideoViewModel = EditingVideoViewModel(videoOutputFileUrl: fileUrl)
        
        // swithing captureImageView to state edtingVideo
        self.screenManagementService.mainScreenService.captureImageViewScreenService.switchTo(screenType: .editCaptureVideo)
    }
    
    func resetEditingViewModel() {
        self.editingViewModel = nil
    }
    
    func resetEditingVideoViewModel() {
        self.editingVideoViewModel = nil
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
            self.objectWillChange.send()
        }).store(in: &cancellables)
    }
    
    
    func subscribeToSetupProfileViewModelPublishers(){
        self.setupProfileViewModel.objectWillChange.sink { (_) in
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    func subscribeToCameraFeedPublishers(){
        Publishers.cameraFeedDidCaptureImagePublisher.sink {(image) in
            self.setupEditingViewModel(withUIImage: image)
        }.store(in: &cancellables)
        
        Publishers.cameraFeedDidCaptureVideoPublisher.sink { (videoFilePathUrl) in
            self.setupEditingVideoViewModel(withVideoFilePathUrl: videoFilePathUrl)
        }.store(in: &cancellables)
    }
    
    func subscribeToRetrievePostPublishers(){
        Publishers.retrievePostServiceDidReceiveAllPosts.sink { (posts) in
            posts.forEach { (post) in
                guard let id = post.id else {
                    return
                }
                
                // checking whether post already exists in the dict or not
                if self.allPosts[id] == nil {
                    self.allPosts[id] = post
                }
            }
        }.store(in: &cancellables)
    }
    
    func setupSubscribers() {
        self.subscribeToUserProfileServicePublishers()
        self.subscribeToScreenManagementServicePublishers()
        self.subscribeToCameraFeedPublishers()
        self.subscribeToRetrievePostPublishers()
    }
    
}


