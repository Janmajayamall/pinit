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
    @Published var username: String = "" {
        didSet{
            print("HHAAA \(self.username)")
        }
    }
    @Published var usernameError: String = ""
     
    private var cancellables: Set<AnyCancellable> = []
    
    init() {}
    
    func postNotification(for notificationType: Notification.Name, withObject object: Any){
        NotificationCenter.default.post(name: notificationType, object: object)
    }
    
    func initiateSetupProfile(withCallback callback: @escaping (Bool) -> Void) {
        
        // checking whether username is already taken or not
        UserProfileService.checkUsernameExists(for: self.username) { (exists) in
            if (exists == true) {
                self.usernameError = "Username already taken"
                callback(false)
            }else {
                self.usernameError = ""
                self.setupProfile(withCallback: callback)
            }
        }
    }
    
    func setupProfile(withCallback callback: (Bool) -> Void){
        
        // creating request for setting up profile for user
        let requestModel = RequestSetupUserProfileModel(username: self.username)
        
        self.postNotification(for: .userProfileServiceDidRequestSetupUserProfile, withObject: requestModel)
        
        callback(true)
    }
}
