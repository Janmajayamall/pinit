//
//  BlockUsersService.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
import Combine

class BlockUsersService: ObservableObject {
    var user: User?
    var blockedUsersListener: ListenerRegistration?
        
    @Published var blockedUsers: Array<BlockedUserModel> = []
    
    private var blockedUsersRef: CollectionReference = Firestore.firestore().collection("blockedUsers")
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.subscribeToAuthenticationServicePublishers()
        self.subscribeToBlockUsersServicePublishers()
    }
    
    func listenToBlockedUsers() {
        self.stopListeningToBlockedUsers()
        
        guard let user = self.user else {return}
        
        self.blockedUsersListener =  self.blockedUsersRef.whereField("blockedByUID", isEqualTo: user.uid).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("Blocked Users snapshot listener failed with error \(error!)")
                return
            }
            
            var blockedUsers: Array<BlockedUserModel> = []
            documents.forEach { (queryDocumentSnapshot) in
                guard let model = try? queryDocumentSnapshot.data(as: BlockedUserModel.self) else {return}
                blockedUsers.append(model)
            }
            
            // send out notification
            self.blockedUsers = blockedUsers
            self.notifyUpdateBlockedUsers()
        }
    }
    
    func notifyUpdateBlockedUsers() {
        NotificationCenter.default.post(name: .blockUsersServiceDidUpdateBlockedUsers, object: self.blockedUsers)
    }
    
    func stopListeningToBlockedUsers(){
        if let listener = self.blockedUsersListener {
            listener.remove()
        }
    }
    
    func checkBlockStatusOverNetwork(forUID otherUserUID: String, withCallback callback: @escaping (BlockStatus) -> Void) {
        guard let user = self.user, user.uid != otherUserUID else {
            callback(.invalid)
            return
        }
                
        self.blockedUsersRef.whereField("blockedByUID", isEqualTo: user.uid).whereField("blockedUID", isEqualTo: otherUserUID).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {return}
            
            if (documents.count == 0){
                callback(.inactive)
            }else {
                callback(.active)
            }
        }
    }
    
    func blockUser(withRequestModel requestBlockUserModel: RequestBlockUserModel){
        // check block status
        self.checkBlockStatusOverNetwork(forUID: requestBlockUserModel.uid) { (blockStatus) in
            guard blockStatus == .inactive, let user = self.user, user.uid != requestBlockUserModel.uid else {return}
            
            // block the user
            let blockUserModel = BlockedUserModel(blockedByUID: user.uid, blockedUID: requestBlockUserModel.uid, blockedUsername: requestBlockUserModel.username)
            _ = try? self.blockedUsersRef.document(blockUserModel.id!).setData(from: blockUserModel)            
        }
    }
    
    func unblockUser(withUID otherUserUID: String){
        guard let user = self.user else {return}
        
        self.blockedUsersRef.whereField("blockedByUID", isEqualTo: user.uid).whereField("blockedUID", isEqualTo: otherUserUID).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {return}
            
            documents.forEach { (queryDocumentSnapshot) in
                queryDocumentSnapshot.reference.delete()
            }
        }
    }
    
    func checkBlockStatus(forUID otherUserUID: String) -> BlockStatus {
        guard let user = self.user, user.uid != otherUserUID else {
            return .invalid
        }
        
        if (self.blockedUsers.contains(where: { (blockedUser) -> Bool in
            return blockedUser.blockedUID == otherUserUID
        })){
            return .active
        }else{
            return .inactive
        }
    }
    
    enum BlockStatus {
        case active
        case inactive
        case invalid
    }
    
}

extension BlockUsersService {
    func subscribeToAuthenticationServicePublishers() {
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (newUser) in
            self.blockedUsers = []
            self.stopListeningToBlockedUsers()
            
            guard let newUser = newUser else {
                // log out the current user
                self.user = nil
                return
            }
            
            self.user = newUser
            self.listenToBlockedUsers()
            return
        }.store(in: &cancellables)
    }
    
    func subscribeToBlockUsersServicePublishers() {
        Publishers.blockUsersServiceDidRequestUnblockUserPublisher.sink { (uid) in
            self.unblockUser(withUID: uid)
        }.store(in: &cancellables)
        
        Publishers.blockUsersServiceDidRequestBlockUserModelPublihser.sink { (requestModel) in
            self.blockUser(withRequestModel: requestModel)
        }.store(in: &cancellables)
    }
}

