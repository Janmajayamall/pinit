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
       
    var cameraFlashMode: AVCaptureDevice.FlashMode = .off
    
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
                                
            }
            
            else if let frontCameraDevice = self.frontCameraDevice {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCameraDevice)
                
                if captureSession.canAddInput(self.frontCameraInput!){
                    captureSession.addInput(self.frontCameraInput!)
                }
                                
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
    
    func switchCameraInUsePosition(to cameraPosition: CameraInUsePosition) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {throw CameraFeedControllerError.captureSessionIsMissing}
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let sessionInput = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, sessionInput.contains(rearCameraInput), let frontCameraDevice = self.frontCameraDevice else {
                throw CameraFeedControllerError.invalidOperation}
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCameraDevice)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!){
                captureSession.addInput(self.frontCameraInput!)
            }else {
                throw CameraFeedControllerError.invalidOperation
            }
        }
        func switchToRearCamera() throws {
            guard let sessionInput = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, sessionInput.contains(frontCameraInput), let rearCameraDevice = self.rearCameraDevice else {
                throw CameraFeedControllerError.invalidOperation
                
            }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCameraDevice)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!){
                captureSession.addInput(self.rearCameraInput!)
            }else {
                throw CameraFeedControllerError.invalidOperation
            }
        }
        
        // toggling camera in use position
        switch cameraPosition {
        case .front:
            try switchToFrontCamera()
        case .rear:
            try switchToRearCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    func captureImage() throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {throw CameraFeedControllerError.captureSessionIsMissing}
        
        let captureSettings = AVCapturePhotoSettings()
        captureSettings.flashMode = self.cameraFlashMode
        
        self.cameraPhotoOutput?.capturePhoto(with: captureSettings, delegate: self)
    }

}

extension CameraFeedController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error{
            print("Capture photo failed with errror: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            print("Unknown error while getting captured image file representation")
            return
        }
        print("Captured Image: \(image)")
        NotificationCenter.default.post(name: .cameraFeedDidCaptureImage, object: image)
    }
}

// extension for subscribing to publishers
extension CameraFeedController {
    func subscribeToCameraFeedPublishers() {
        Publishers.cameraFeedSwitchInUseCameraPublisher.sink { (cameraPosition) in
            do {
                try self.switchCameraInUsePosition(to: cameraPosition)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
        
        Publishers.cameraFeedSwitchFlashModePublisher.sink { (flashMode) in
            self.cameraFlashMode = flashMode
        }.store(in: &cancellables)
        
        Publishers.cameraFeedDidRequestCaptureImagePublisher.sink { (value) in
            guard value else {return}
            
            do{
                try self.captureImage()
            }catch{
                print("Camera Feed capture image failed with error: \(error)")
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
