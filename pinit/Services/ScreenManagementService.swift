//
//  ScreenManagementService.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine

//enum MainScreenType {
//    case mainArView
//    case captureImage
//
//    weak var manager: ScreenManagementService?
//
//    init(){
//        self = .mainArView
//    }
//
//    mutating func switchToCaptureImage(withManager manager: ScreenManagementService){
//        guard manager.activeMainScreenOverlay == .none else {return}
//        self = .captureImage
//    }
//
//    mutating func switchTomainArView(withManager manager: ScreenManagementService){
//        self = .mainArView
////        manager.activeCaptureImageScreen = .cameraFeed
//    }
//}

enum ProfileViewScreenType{
    case editUsername
    case editProfileImage
    case settings
    case normal
}

struct ProfileViewScreenService: ScreenService {
    
    var activeType: ProfileViewScreenType = .normal
    
    mutating func switchTo(screenType type: ProfileViewScreenType) {
        switch type {
        case .normal:
            self.switchToNormal()
        case .editProfileImage:
            self.switchToEditProfileImage()
        case .editUsername:
            self.switchToEditUsername()
        case .settings:
            self.switchToSettings()
        }
    }
    
    mutating func switchToNormal() {
        self.activeType = .normal
    }
    
    private mutating func switchToEditUsername() {
        self.activeType = .editUsername
    }
    
    private mutating func switchToEditProfileImage() {
        self.activeType = .editProfileImage
    }
    
    private mutating func switchToSettings() {
        self.activeType = .settings
    }
    
    mutating func resetScreen() {
        self.activeType = .normal
    }
}

enum CaptureImageScreenType {
    case cameraFeed
    case imageEditing
    
    init(){
        self = .cameraFeed
    }
}

enum SetupProfileViewScreenType {
    case pickImage
    case normal
}

struct SetupProfileViewScreenService: ScreenService {
    var activeType: SetupProfileViewScreenType = .normal
    
    mutating func switchTo(screenType type: SetupProfileViewScreenType) {
        switch type {
        case .normal:
            self.switchToNormal()
        case .pickImage:
            self.switchToPickImage()
        }
    }
    
    mutating private func switchToPickImage() {
        self.activeType = .pickImage
    }
    
    mutating private func switchToNormal() {
        self.activeType = .normal
    }
    
    mutating func resetScreen() {
        self.activeType = .normal
    }
}

enum MainArViewScreenType {
    case login
    case profile
    case setupProfile
    case normal
}

struct MainArViewScreenService: ScreenService {
    var activeType: MainArViewScreenType = .normal
    var profileViewScreenService: ProfileViewScreenService = ProfileViewScreenService()
    var setupProfileViewScreenService: SetupProfileViewScreenService = SetupProfileViewScreenService()
    
    mutating func switchTo(screenType type: MainArViewScreenType){
        
        self.resetScreenServices()
        
        switch type {
        case .login:
            self.switchToLogin()
        case .profile:
            self.switchToProfile()
        case .normal:
            self.switchToNormal()
        case .setupProfile:
            self.switchToSetupProfile()
        }
    }
    
    private mutating func switchToLogin() {
        self.activeType = .login
    }
    
    private mutating func switchToProfile() {
        self.activeType = .profile
    }
    
    private mutating func switchToNormal() {
        self.activeType = .normal
    }
      
    private mutating func switchToSetupProfile() {
        self.activeType = .setupProfile
    }
    
    mutating func resetScreen() {
        self.resetScreenServices()
        
        self.activeType = .normal
    }
    
    mutating func resetScreenServices() {
        // resetting profile view screen, if it was active
        self.profileViewScreenService.resetScreen()
        
        // resetting setup profile view screen, if it was active
        self.setupProfileViewScreenService.resetScreen()
    }
}

enum CaptureImageViewScreenType {
    case normal
    case editCaptureImage
    case editCaptureVideo
}

struct CaptureImageViewScreenService: ScreenService {
    var activeType: CaptureImageViewScreenType = .normal
    
    mutating func switchTo(screenType type: CaptureImageViewScreenType){
        switch type {
        case .normal:
            self.switchToNormal()
        case .editCaptureImage:
            self.switchToEditCaptureImage()
        case .editCaptureVideo:
            self.switchToEditCaptureVideo()
        }
    }
    
    private mutating func switchToNormal() {
        self.activeType = .normal
    }
    
    private mutating func switchToEditCaptureImage() {
        self.activeType = .editCaptureImage
    }
    
    private mutating func switchToEditCaptureVideo() {
        self.activeType = .editCaptureVideo
    }
    
    mutating func resetScreen(){
        self.activeType = .normal
    }
}

enum MainScreenType {
    case mainArView
    case captureImageView
}

struct MainScreenService: ScreenService {
    
    var activeType: MainScreenType = .mainArView
    var mainArViewScreenService: MainArViewScreenService = MainArViewScreenService()
    var captureImageViewScreenService: CaptureImageViewScreenService = CaptureImageViewScreenService()
    
    mutating func switchTo(screenType type: MainScreenType){
        switch type {
        case .captureImageView:
            self.switchToCaputureImageView()
        default:
            self.switchToMainArView()
        }
    }
    
    mutating func switchToSetupUserProfile(){
        self.switchTo(screenType: .mainArView)
        self.mainArViewScreenService.switchTo(screenType: .setupProfile)
    }
    
    private mutating func switchToCaputureImageView() {
        self.activeType = .captureImageView
        
        // reset mainArView screen
        self.mainArViewScreenService.resetScreen()
    }
    
    private mutating func switchToMainArView() {
        self.activeType = .mainArView
        
        // reset captureImageView Screen after switching screen, so it does not looks glitchy
        self.captureImageViewScreenService.resetScreen()        
    }
        
    mutating func resetScreen() {
        self.mainArViewScreenService.resetScreen()
        self.captureImageViewScreenService.resetScreen()
        
        self.activeType = .mainArView
        
        
        
    }
}

class ScreenManagementService: ObservableObject {
    @Published var mainScreenService: MainScreenService = MainScreenService()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(){
        self.subscribeToUserProfileServicePublishers()
        self.subscribeToAuthenticationServicePublishers()
    }
    
    
}

// for subscribing to notifications
extension ScreenManagementService {
    func subscribeToUserProfileServicePublishers(){
        Publishers.userProfileServiceDidNotFindUserProfilePublisher.sink { (user) in
            self.mainScreenService.switchToSetupUserProfile()
        }.store(in: &cancellables)
    }
    
    func subscribeToAuthenticationServicePublishers(){
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (user) in
            self.mainScreenService.resetScreen()
        }.store(in: &cancellables)
    }
    
}


protocol ScreenService {
    associatedtype ScreenType
    
    mutating func switchTo(screenType type: ScreenType)
    mutating func resetScreen()
}
