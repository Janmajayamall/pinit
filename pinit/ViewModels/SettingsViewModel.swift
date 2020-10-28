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
import AVFoundation

class SettingsViewModel: ObservableObject {
    @Published var user: User?
    @Published var userProfile: ProfileModel?
    @Published var userPostCount: Int = 0
    
    // all indicators
    @Published var internetErrorConnectionIndicator: Bool = false
    @Published var postsDoNotExistIndicator: Int = 0
    @Published var loadIndicator: Int = 0
    @Published var uploadIndicator: Int = 0
    @Published var refreshIndicator: Int = 0
    @Published var postDisplayNotification: Bool = false
    @Published var sceneDidResetNotification: Bool = false
    
    @Published var postDisplayType: PostDisplayType = .allPosts
    @Published var popUpWarningType: PopUpWarningType = .none
    
    // services
    private var authenticationService = AuthenticationService()
    private var retrievePostService = RetrievePostService()
    @Published var userProfileService = UserProfileService()
    @Published var screenManagementService = ScreenManagementService()
    private var locationService = LocationService()
    private var estimatedUserLocationService = EstimatedUserLocationService()
    private var uploadPostService = UploadPostService()
    private var geohasingService = GeohashingService()
    private var analyticsService = AnalyticsService()
    private var additionalDataService = AdditionalDataService()
    @Published var blockUsersService = BlockUsersService()
    
    // view models
    @Published var editingViewModel: EditingViewModel?
    @Published var editingVideoViewModel: EditingVideoViewModel?
    @Published var blockUserViewModel: BlockUserViewModel = BlockUserViewModel()
    @Published var onboardingViewModel: OnboardingViewModel = OnboardingViewModel()
    
    
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
        self.estimatedUserLocationService.setupService()
        self.locationService.setupService()
        //        self.authenticationService.setupService()
    }
    
    func checkDevicePermissions() -> Bool {
        // checking camera permission
        var cameraAuthorised: Bool {
            return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        }
        
        // checking location permission
        var locationAuthorised: Bool {
            let locationPermission = CLLocationManager.authorizationStatus()
            
            return locationPermission == .authorizedAlways || locationPermission == .authorizedWhenInUse
        }
        
        // set pop up warning
        if (cameraAuthorised == false && locationAuthorised == false){
            self.popUpWarningType = .locationAndCameraPermissionUnavailable
        } else if (cameraAuthorised == false && locationAuthorised == true){
            self.popUpWarningType = .cameraPermissionUnavailable
        } else if (cameraAuthorised == true && locationAuthorised == false){
            self.popUpWarningType = .locationPermissionUnavailable
        } else {
            self.popUpWarningType = .none
        }
        
        // set the mainArView to warning type
        if (cameraAuthorised == false || locationAuthorised == false){
            self.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .popUpWarning)
        } else {
            self.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
        }
        
        return cameraAuthorised && locationAuthorised
    }     
    
    func handleSceneDidBecomeActive() {        
        guard self.checkDevicePermissions() else {
            return
        }
        
        // start authentication service
        self.authenticationService.startService()
        
        AnalyticsService.logAppOpenEvent()
        
        if (self.user != nil && self.onboardingViewModel.checkOnboardingStatus(for: .authenticatedMainARView) < MainOnboardingAuthenticatedView.ScreenNumber.getMaxScreenNumber()){
            return
        }
        
        self.startScene()
                
    }
    
    func startScene() {
        // start pulse loader
        self.handleLoadIndicator()
        
        // start the session setup GroupSCNNodes in AppARSCNNodes
        self.appArScnView.startSession()
        self.appArScnView.setupGroupNodes(withInitialPostDisplayType: self.postDisplayType)
        
        // update blocked list
        self.blockUsersService.notifyUpdateBlockedUsers()
        
        // start geohashing service
        self.geohasingService.startService()
        
        // start estimated location service
        self.estimatedUserLocationService.startService()
        
        // start location service
        self.locationService.startService()
        
        // update user last active & log app open event
        self.userProfileService.updateUserActiveData()
    }
    
    func handleSceneWillResignActive() {
        self.stopScene()
        
        // reset default values
        internetErrorConnectionIndicator = false
        postsDoNotExistIndicator = 0
        loadIndicator = 0
        uploadIndicator = 0
        refreshIndicator = 0
        postDisplayNotification = false
        sceneDidResetNotification = false
        
        postDisplayType = .allPosts
        popUpWarningType = .none
    }
    
    func stopScene() {
        // stop location service
        self.locationService.stopService()
        
        // stop estimated location service
        self.estimatedUserLocationService.stopService()
        
        // stop geohashing service
        self.geohasingService.stopService()
        
        // mute all av player
        NotificationCenter.default.post(name: .postDisplayNodeModelDidRequestMuteAVPlayer, object: nil)
        
        // stop session & remove GroupSCNNodes in AppARSCNNodes
        self.appArScnView.pauseSession()
        self.appArScnView.removeGroupNodes()
        
        // stop authentication service
        self.authenticationService.stopService()
    }
    
    func refreshScene() {
        self.handleLoadIndicator()
        
        guard self.refreshIndicator == 0 else {return}
    
        // REMOVE STUFF
        self.geohasingService.stopService()
        // remove GroupSCNNodes in AppArSCNNodes
        self.appArScnView.removeGroupNodes()
        
        // START STUFF
        // add group scn nodes to the session
        self.appArScnView.setupGroupNodes(withInitialPostDisplayType: self.postDisplayType)
        // update blocked list
        self.blockUsersService.notifyUpdateBlockedUsers()
        // start geohashing service
        self.geohasingService.startService()
        // notify current location from estimated user location
        self.estimatedUserLocationService.notifyCurrentLocation()
              
        // handle refresh
        self.handleRefreshIndicator()
        
    }
    
    func isUserAuthenticated() -> Bool {
        return self.user != nil
    }
    
    func handleLoadIndicator() {
        if (self.loadIndicator == 0){
            self.loadIndicator = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.loadIndicator = 0
                if self.appArScnView.exisitingPosts.count == 0 {
                    self.handlePostsDoNotExistIndicator()
                }
            })
        }
    }
    
    func handleRefreshIndicator() {
        if (self.refreshIndicator == 0){
            self.refreshIndicator = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                self.refreshIndicator = 0
            }
        }
    }
    
    func handlePostsDoNotExistIndicator() {
        if (self.postsDoNotExistIndicator == 0){
            self.postsDoNotExistIndicator = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.postsDoNotExistIndicator = 0
            })
        }
    }
    
    func signOut() {
        // logging out from firebase auth
        print("Did request sign out")
        self.authenticationService.signOut()
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
    
    func togglePostDisplayType() {
        switch self.postDisplayType {
        case .allPosts:
            self.postDisplayType = .privatePosts
        case .privatePosts:
            self.postDisplayType = .allPosts
        }
        
        // post notification for group scn node
        NotificationCenter.default.post(name: .groupSCNNodeDidRequestChangePostDisplayType, object: self.postDisplayType)
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
    }
    
    func subscribeToScreenManagementServicePublishers() {
        self.screenManagementService.objectWillChange.sink(receiveValue: { value in
            self.objectWillChange.send()
        }).store(in: &cancellables)
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
        Publishers.retrievePostServiceDidReceiveUserPostsPublisher.sink { (posts) in
            self.userPostCount = posts.count
        }.store(in: &cancellables)
    }
    
    func subscribeToGeneralFunctionPublishers() {
        Publishers.generalFunctionDidFailInternetConnectionPublisher.sink { (value) in
            guard value == true else {return}
            self.internetErrorConnectionIndicator = true
            
            // make error false after sometime
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                self.internetErrorConnectionIndicator = false
            })
        }.store(in: &cancellables)
//
//        Publishers.generalFunctionManipulateTaskForLoadIndicatorPublisher.sink { (value) in
//            self.loadIndicator -= 1
//        }.store(in: &cancellables)
        
        Publishers.generalFunctionManipulateTaskForUploadIndicatorPublisher.sink { (value) in
            guard value != 0 else {return}
            
            if (value > 0){
                self.uploadIndicator += 1
            }else if (value < 0 && self.uploadIndicator > 0){
                self.uploadIndicator -= 1
            }else {
                self.uploadIndicator = 0
            }
        }.store(in: &cancellables)
//
//        Publishers.generalFunctionPostsDoNotExistForCurrentLocationPublisher.sink { (value) in
//            guard value == true else {return}
//
//            self.postsDoNotExistIndicator = true
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                self.postsDoNotExistIndicator = false
//            })
//        }.store(in: &cancellables)
    }
    
    func subscribeToBlockUsersServicePublishers() {
        self.blockUsersService.objectWillChange.sink { _ in            
            self.objectWillChange.send()
        }.store(in: &cancellables)
        self.blockUserViewModel.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    func subscribeToOnboardigPublishers() {
        self.onboardingViewModel.objectWillChange.sink { _ in
            print("Onboarding did change")
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    func setupSubscribers() {
        self.subscribeToUserProfileServicePublishers()
        self.subscribeToScreenManagementServicePublishers()
        self.subscribeToCameraFeedPublishers()
        self.subscribeToRetrievePostPublishers()
        self.subscribeToGeneralFunctionPublishers()
        self.subscribeToBlockUsersServicePublishers()
        self.subscribeToOnboardigPublishers()
    }
}
