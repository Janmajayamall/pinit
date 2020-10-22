//
//  BlockUserViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

class BlockUserViewModel: ObservableObject {
    
    @Published var searchedUser: OtherUserModel?
    @Published var searchString: String = "" {
        didSet{            
            self.searchedUser = nil
            self.getUsers(withSearchString: self.searchString)
        }
    }
    
    var usersCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    
    func getUsers(withSearchString searchString: String) {    
        self.usersCollectionRef.whereField("username", isEqualTo: searchString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)).getDocuments(completion: { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {return}
    
            documents.forEach { (queryDocumentSnapshot) in
                guard let userProfile = try? queryDocumentSnapshot.data(as: ProfileModel.self) else {return}
                let otherUser = OtherUserModel(uid: userProfile.id!, username: userProfile.username)
                self.searchedUser = otherUser
            }
            
                        
        })
    }
    
    
    
    
}
