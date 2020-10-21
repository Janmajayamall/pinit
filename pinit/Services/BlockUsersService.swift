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
    
    var displayedUsers: Array<OtherUserModel> = []
    @Published var blockedUsers: Array<BlockedUserModel> = [BlockedUserModel(blockedByUID: "dawaxa", blockedUID: "dawdadadw", blockedUsername: "dawdawda"), BlockedUserModel(blockedByUID: "dawaxa", blockedUID: "dawdadadw", blockedUsername: "dawdawda"), BlockedUserModel(blockedByUID: "dawaxa", blockedUID: "dawdadadw", blockedUsername: "dawdawda"), BlockedUserModel(blockedByUID: "dawaxa", blockedUID: "dawdadadw", blockedUsername: "dawdawda")
    ]
    
    private var blockedUsersRef: CollectionReference = Firestore.firestore().collection("BlockedUsers")
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.subscribeToAuthenticationServicePublishers()
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
//            self.blockedUsers = blockedUsers
        }
    }
    
    func stopListeningToBlockedUsers(){
        if let listener = self.blockedUsersListener {
            listener.remove()
        }
    }
    
    func checkBlockStatusOverNetwork(forUID otherUserUID: String, withCallback callback: (BlockStatus) -> Void) {
        guard let user = self.user else {
            callback(.inactive)
            return
        }
        
        var blockStatus: BlockStatus?
        self.blockedUsersRef.whereField("blockedByUID", isEqualTo: user.uid).whereField("blockedUID", isEqualTo: otherUserUID).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {return}
            
            if (documents.count == 0){
                blockStatus = .inactive
            }else {
                blockStatus = .active
            }
        }
        
        if (blockStatus == nil){
            callback(.inactive)
        }else {
            callback(blockStatus!)
        }
    }
    
    func blockUser(withRequestModel requestBlockUserModel: RequestBlockUserModel){
        
        // check block status
        self.checkBlockStatusOverNetwork(forUID: requestBlockUserModel.uid) { (blockStatus) in
            guard blockStatus == .inactive, let user = self.user else {return}
            
            // block the user
            let blockUserModel = BlockedUserModel(blockedByUID: user.uid, blockedUID: requestBlockUserModel.uid, blockedUsername: requestBlockUserModel.username)
            _ = try? self.blockedUsersRef.document(blockUserModel.id!).setData(from: blockUserModel)
        }
    }
    
    func unblockUser(withUID uid: String){
        guard let user = self.user else {return}
        
        self.blockedUsersRef.whereField("blockedByUID", isEqualTo: user.uid).whereField("blockedUID", isEqualTo: uid).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {return}
            
            documents.forEach { (queryDocumentSnapshot) in
                queryDocumentSnapshot.reference.delete()
            }
        }
    }
    
    func checkBlockStatus(forUID uid: String) -> BlockStatus {    
        guard let user = self.user, user.uid != uid else {
            print("SDFFF ", uid, " invalid")
            return .invalid
        }
        
        if (self.blockedUsers.contains(where: { (blockedUser) -> Bool in
            return blockedUser.blockedUID == uid
        })){
            return .active
        }
        print("inactive")
        return .inactive
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
            guard let newUser = newUser else {
                // log out the current user
                self.user = nil
                self.stopListeningToBlockedUsers()
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

