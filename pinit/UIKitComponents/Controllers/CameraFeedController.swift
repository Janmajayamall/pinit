//
//  CameraFeedController.swift
//  pinit
//
//  Created by Janmajaya Mall on 2/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Combine

class CameraFeedController: NSObject {
    
    var captureSession: AVCaptureSession?
    
    var frontCameraDevice: AVCaptureDevice?
    var frontCameraInput: AVCaptureInput?
    
    var rearCameraDevice: AVCaptureDevice?
    var rearCameraInput: AVCaptureInput?
    
    var cameraPhotoOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var cameraInUsePosition: CameraInUsePosition?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init(){
        super.init()
        
        // subscribing to publishers
        self.subscribeToCameraFeedPublishers()
    }
}

extension CameraFeedController {
    /// sets up the session along with creating connections for all required inputs & outputs
    ///
    /// prepareController will not be called in init, because setting up AVCaptureSession is expensive
    /// , hence will be called after initialisation
    func prepareController(withCompletionHandler completionHandler: @escaping (Error?) -> Void){
        
        // defining functions for setting up the session, devices, inputs from devices, and outputs
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        func setupCaptureDevices() throws {
            // discovery session for finding all capture devices
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            let captureDevices = discoverySession.devices.compactMap({$0})
            if captureDevices.isEmpty {throw CameraFeedControllerError.noCamerasAvailable}
            
            // setting up capture devices
            for captureDevice in captureDevices {
                if captureDevice.position == .front {
                    self.frontCameraDevice = captureDevice
                }
                
                if captureDevice.position == .back {
                    self.rearCameraDevice = captureDevice
                    
                    try self.rearCameraDevice?.lockForConfiguration()
                    self.rearCameraDevice?.focusMode = .continuousAutoFocus
                    self.rearCameraDevice?.unlockForConfiguration()
                }
            }
        }
        func setupDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraFeedControllerError.captureSessionIsMissing}
            
            if let rearCameraDevice = self.rearCameraDevice {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCameraDevice)
                
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                }
                
                self.cameraInUsePosition = .rear
            }
            
            else if let frontCameraDevice = self.frontCameraDevice {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCameraDevice)
                
                if captureSession.canAddInput(self.frontCameraInput!){
                    captureSession.addInput(self.frontCameraInput!)
                }
                
                self.cameraInUsePosition = .front
            }
            
            else {
                throw CameraFeedControllerError.noCamerasAvailable
            }
        }
        func setupCameraPhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraFeedControllerError.captureSessionIsMissing}
            
            self.cameraPhotoOutput = AVCapturePhotoOutput()
            self.cameraPhotoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.cameraPhotoOutput!) {
                captureSession.addOutput(self.cameraPhotoOutput!)
            }
            
            captureSession.startRunning()
        }
        
        // setting up everything
        DispatchQueue(label: "prepare").async {
            do{
                createCaptureSession()
                try setupCaptureDevices()
                try setupDeviceInputs()
                try setupCameraPhotoOutput()
            }catch{
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayViewPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {throw CameraFeedControllerError.captureSessionIsMissing}
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
   
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func switchCameraInUsePosition() throws {
        guard let cameraInUsePosition = self.cameraInUsePosition, let captureSession = self.captureSession, captureSession.isRunning else {throw CameraFeedControllerError.captureSessionIsMissing}
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let sessionInput = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, sessionInput.contains(rearCameraInput), let frontCameraDevice = self.frontCameraDevice else {
                print("ya")
                throw CameraFeedControllerError.invalidOperation}
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCameraDevice)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!){
                captureSession.addInput(self.frontCameraInput!)
                
                self.cameraInUsePosition = .front
            }else {
                print("yaa")
                throw CameraFeedControllerError.invalidOperation
            }
        }
        func switchToRearCamera() throws {
            guard let sessionInput = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, sessionInput.contains(frontCameraInput), let rearCameraDevice = self.rearCameraDevice else {
                print("ya")
                throw CameraFeedControllerError.invalidOperation
                
            }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCameraDevice)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!){
                captureSession.addInput(self.rearCameraInput!)
                
                self.cameraInUsePosition = .rear
            }else {
                print("yaa")
                throw CameraFeedControllerError.invalidOperation
            }
        }
        
        // toggling camera in use position
        switch cameraInUsePosition {
        case .front:
            try switchToRearCamera()
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
}

// extension for subscribing to publishers
extension CameraFeedController {
    func subscribeToCameraFeedPublishers() {
        Publishers.cameraFeedSwitchInUseCameraPublisher.sink { (bool) in
            guard bool else {return}
            print("received")
            do {
                try self.switchCameraInUsePosition()
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
}

extension CameraFeedController {
    enum CameraFeedControllerError: Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    enum CameraInUsePosition {
        case front
        case rear
    }
}
