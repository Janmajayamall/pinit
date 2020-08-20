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

enum MainArViewScreenType {
    case login
    case profile
    case normal
}

struct MainArViewScreenService: ScreenService {
    var activeType: MainArViewScreenType = .normal
    var profileViewScreenService: ProfileViewScreenService = ProfileViewScreenService()
    
    mutating func switchTo(screenType type: MainArViewScreenType){
        switch type {
        case .login:
            self.switchToLogin()
        case .profile:
            self.switchToProfile()
        case .normal:
            self.switchToNormal()
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
    
    mutating func resetScreen() {
        //TODO: fix child as well
        self.activeType = .normal
    }
}

enum CaptureImageViewScreenType {
    case normal
    case editCaptureImage
}

struct CaptureImageViewScreenService: ScreenService {
    var activeType: CaptureImageViewScreenType = .normal
    
    mutating func switchTo(screenType type: CaptureImageViewScreenType){
        switch type {
        case .normal:
            self.switchToNormal()
        case .editCaptureImage:
            self.switchToEditCaptureImage()
        }
    }
    
    private mutating func switchToNormal() {
        self.activeType = .normal
    }
    
    private mutating func switchToEditCaptureImage() {
        self.activeType = .editCaptureImage
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
    
    private mutating func switchToCaputureImageView() {
        // reset mainArView screen before the switch
        self.mainArViewScreenService.resetScreen()
        
        self.activeType = .captureImageView
    }
    
    private mutating func switchToMainArView() {
        // reset captureImageView Screen before switch
        self.captureImageViewScreenService.resetScreen()
        
        self.activeType = .mainArView
    }
    
    func resetScreen() {
        print("screen reset")
    }
}

class ScreenManagementService: ObservableObject {
    @Published var mainScreenService: MainScreenService = MainScreenService()
}


protocol ScreenService {
    associatedtype ScreenType
    
    mutating func switchTo(screenType type: ScreenType)
    mutating func resetScreen()
}
