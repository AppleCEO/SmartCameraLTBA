//
//  ViewController.swift
//  SmartCameraLTBA
//
//  Created by joon-ho kil on 2019/11/01.
//  Copyright © 2019 joon-ho kil. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var identifier: UILabel!
    @IBOutlet weak var confidence: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
    
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
//        let request = VNCoreMLRequest(model: VNCoreMLModel, completionHandler: VNRequestCompletionHandler?)
//        VNImageRequestHandler(cgImage: CGImage, options: <#T##[VNImageOption : Any]#>)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else { return }
        let request = VNCoreMLRequest(model: model) {
             (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            DispatchQueue.main.async {
                self.identifier.text = firstObservation.identifier
                self.confidence.text = String(firstObservation.confidence)
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

