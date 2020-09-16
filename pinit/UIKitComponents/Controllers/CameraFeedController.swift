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
import Firebase
import FirebaseStorage

class CameraFeedController: NSObject {
    
    var captureSession: AVCaptureSession?
    
    var frontCameraDevice: AVCaptureDevice?
    var frontCameraInput: AVCaptureInput?
    
    var rearCameraDevice: AVCaptureDevice?
    var rearCameraInput: AVCaptureInput?
    
    var audioDevice: AVCaptureDevice?
    var audioInput: AVCaptureInput?
    
    var cameraPhotoOutput: AVCapturePhotoOutput?
    var cameraMovieOutput: AVCaptureMovieFileOutput?
    
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
            
            self.audioDevice = AVCaptureDevice.default(for: .audio)
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
            
            if let audioDevice = self.audioDevice {
                self.audioInput = try AVCaptureDeviceInput(device: audioDevice)
                
                if captureSession.canAddInput(self.audioInput!) {
                    captureSession.addInput(self.audioInput!)
                }
            }
        }
        func setupOutputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraFeedControllerError.captureSessionIsMissing
            }
            
            self.cameraPhotoOutput = AVCapturePhotoOutput()
            self.cameraPhotoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.cameraPhotoOutput!) {
                captureSession.addOutput(self.cameraPhotoOutput!)
            }
            
            self.cameraMovieOutput = AVCaptureMovieFileOutput()
            
            if captureSession.canAddOutput(self.cameraMovieOutput!) {
                captureSession.addOutput(self.cameraMovieOutput!)
            }
            
            captureSession.startRunning()
        }
        
        // setting up everything
        DispatchQueue(label: "prepare").async {
            do{
                createCaptureSession()
                try setupCaptureDevices()
                try setupDeviceInputs()
                try setupOutputs()
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
            let sessionInput = captureSession.inputs
            guard let rearCameraInput = self.rearCameraInput, sessionInput.contains(rearCameraInput), let frontCameraDevice = self.frontCameraDevice else {
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
            let sessionInput = captureSession.inputs
            guard let frontCameraInput = self.frontCameraInput, sessionInput.contains(frontCameraInput), let rearCameraDevice = self.rearCameraDevice else {
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
    
    func switchCameraOutputType(to cameraOutputType: CameraOutputType ) throws {
        guard let captureSession = self.captureSession else {
            throw CameraFeedControllerError.captureSessionIsMissing
        }
        print(cameraOutputType, ": Here is the type")
        switch cameraOutputType {
        case .photo:
            self.cameraPhotoOutput = AVCapturePhotoOutput()
            self.cameraPhotoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.cameraPhotoOutput!) {
                print("Yes")
                captureSession.addOutput(self.cameraPhotoOutput!)
            }
        case .video:
            self.cameraMovieOutput = AVCaptureMovieFileOutput()
            
            if captureSession.canAddOutput(self.cameraMovieOutput!) {
                print("Yes")
                captureSession.addOutput(self.cameraMovieOutput!)
            }
        }
        captureSession.startRunning()
    }
    
    func captureImage() throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {throw CameraFeedControllerError.captureSessionIsMissing}
        
        
        let connection = self.cameraPhotoOutput!.connection(with: AVMediaType.video)
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = .portrait
        }
        if let deviceInput = captureSession.inputs.first as? AVCaptureDeviceInput, deviceInput.device.position != .back {
            connection?.isVideoMirrored = true
        }
        
        let captureSettings = AVCapturePhotoSettings()
        captureSettings.flashMode = self.cameraFlashMode
        
        
        self.cameraPhotoOutput?.capturePhoto(with: captureSettings, delegate: self)
    }
    
    func toggleRecordingVideo() throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {throw CameraFeedControllerError.captureSessionIsMissing}
        
        guard let movieOutput = self.cameraMovieOutput else {return}
        if movieOutput.isRecording == false {
            let connection = self.cameraMovieOutput!.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)! {                
                connection?.videoOrientation = .portrait
            }
            
            if let deviceInput = captureSession.inputs.first as? AVCaptureDeviceInput, deviceInput.device.position != .back {
                connection?.isVideoMirrored = true
            }
            
            // generating output file url for movie
            let directory = NSTemporaryDirectory() as NSString
            let path = directory.appendingPathComponent("\(UUID().uuidString)-\("PinIt").mp4")
            let outputFileUrl =  URL(fileURLWithPath: path)
            
            movieOutput.startRecording(to: outputFileUrl, recordingDelegate: self)
        }else {
            //stop recording
            movieOutput.stopRecording()
        }
    }
    
}

extension CameraFeedController: AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error{
            print("Capture photo failed with error: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            print("Unknown error while getting captured image file representation")
            return
        }
        print("Captured Image: \(image)")
        NotificationCenter.default.post(name: .cameraFeedDidCaptureImage, object: image)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("File outout failed with errror: \(error.localizedDescription)")
            return
        }
        print("outputFileUrl for video: \(outputFileURL)")
        
        // notify that video recorded has been stored in tmp file for application
        NotificationCenter.default.post(name: .cameraFeedDidCaptureVideo, object: outputFileURL)
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
        
        Publishers.cameraFeedSwitchCameraOutputTypePublishser.sink { (outputType) in
            
            do {
                try self.switchCameraOutputType(to: outputType)
            }catch{
                print("Camera Feed Switch Output type for \(outputType) failed with error \(error)")
            }
        }.store(in: &cancellables)
        
        Publishers.cameraFeedDidRequestToggleRecordingVideoPublisher.sink { (value) in
            guard value == true else {return}
            
            do{
                try self.toggleRecordingVideo()
            }catch{
                print("Toggle recording video faile with error \(error)")
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
    
    enum CameraOutputType {
        case video
        case photo
    }
}
