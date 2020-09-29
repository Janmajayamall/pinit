//
//  UIKitSafariWebView.swift
//  pinit
//
//  Created by Janmajaya Mall on 29/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import SafariServices

struct UIKitSafariWebView: UIViewControllerRepresentable {
    
    var url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariView = SFSafariViewController(url: self.url)
        
        // setting the tint color
        safariView.preferredBarTintColor = UIColor(named: "primaryColor")
        // setting button colot
        safariView.preferredControlTintColor = UIColor.white
        
        return safariView
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

