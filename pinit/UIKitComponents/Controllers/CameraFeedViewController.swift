//
//  CameraFeedViewController.swift
//  pinit
//
//  Created by Janmajaya Mall on 2/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

final class CameraFeedViewController: UIViewController {
    let cameraFeedController: CameraFeedController = CameraFeedController()
    var previewView: UIView!
    
    override func viewDidLoad() {
        
        self.previewView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.previewView.contentMode = UIView.ContentMode.scaleAspectFit
        self.view.addSubview(self.previewView)
        
        self.cameraFeedController.prepareController { (error) in
            if let error = error{
                print(error)
                return
            }
            
            try? self.cameraFeedController.displayViewPreview(on: self.previewView)
        }
    }
}

extension CameraFeedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraFeedViewController {
        return CameraFeedViewController()
    }
    
    func updateUIViewController(_ uiViewController: CameraFeedViewController, context: Context) {
        
    }
    
    
}
