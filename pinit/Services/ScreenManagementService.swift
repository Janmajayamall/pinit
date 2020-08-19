//
//  ScreenManagementService.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine

enum MainScreenType {
    case mainArView
    case captureImage
}

enum MainScreenOverlays {
    case profile
    case login
    case none
}

enum ProfileScreenOverlays {
    case changeProfileImage
    case changeUsername
    case none
}


enum CaptureImageScreenType {
    case cameraFeed
    case imageEditing
}


class ScreenManagementService: ObservableObject {
    
    @Published var activeMainScreen: MainScreenType = .mainArView
    @Published var activeMainScreenOverlay: MainScreenOverlays = .none
        
    @Published var activeCaptureImageScreen: CaptureImageScreenType = .cameraFeed

    @Published var activeProfileScreenOverlay: ProfileScreenOverlays = .none
    
    func resetActiveScreens(){
//        self.activeMainScreen = .
    }
    
    private var defaultActiveMainScreen: MainScreenType = .mainArView
    private var defaultActiveCaptureImageScreen: CaptureImageScreenType = .cameraFeed
    private var defaultActiveMainScreenOver
}

extension ScreenManagementService {
    func openMainArView(){
        self.resetActiveScreens()
    }
    
    func openCaptureImageView(){
        guard self.activeMainScreenOverlay == .none else{return}
        self.activeMainScreen = .captureImage
    }
}

extension ScreenManagementService {
    func openLoginView(){
        guard self.activeMainScreen == .mainArView && self.activeMainScreenOverlay == .none else {return}
        self.activeMainScreenOverlay = .login
    }
    
    func validStateForActiveMainScreenOverlay
}
