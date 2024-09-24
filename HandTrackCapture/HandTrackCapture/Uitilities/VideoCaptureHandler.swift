//
//  VideoCaptureHandler.swift
//  HandTrackCapture
//
//  Created by Chiaote Ni on 2024/9/24.
//

import AVFoundation
import CoreImage

final class VideoCaptureHandler: NSObject {

    // Public properties
    let captureSession = AVCaptureSession()

    // Private properties
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private let defaultVideoDevice = AVCaptureDevice.default(for: .video)
    private let captureQueue = DispatchQueue(label: "com.example.VideoCaptureQueue")
    private var sampleBufferCallback: ((CMSampleBuffer) -> Void)?

    // Authorization status
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var authorized = status == .authorized
            if status == .notDetermined {
                authorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return authorized
        }
    }

    // Initializer
    override init() {
        super.init()
        Task {
            await configureCaptureSession()
            await startCaptureSession()
        }
    }

    // Configure the capture session
    private func configureCaptureSession() async {
        guard await isAuthorized,
              let videoDevice = defaultVideoDevice,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice)
        else { return }

        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput?.setSampleBufferDelegate(self, queue: captureQueue)

        guard captureSession.canAddInput(videoDeviceInput),
              captureSession.canAddOutput(videoDataOutput!) else { return }

        captureSession.addInput(videoDeviceInput)
        captureSession.addOutput(videoDataOutput!)

        self.videoDeviceInput = videoDeviceInput
    }

    // Start the capture session
    private func startCaptureSession() async {
        guard await isAuthorized else { return }
        captureSession.startRunning()
    }

    // Set sample buffer callback
    func setSampleBufferCallback(_ callback: @escaping (CMSampleBuffer) -> Void) {
        sampleBufferCallback = callback
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoCaptureHandler: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        sampleBufferCallback?(sampleBuffer)
    }
}

// MARK: - CMSampleBuffer Extension

extension CMSampleBuffer {
    var cgImage: CGImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        return CIImage(cvPixelBuffer: pixelBuffer).cgImage
    }
}

// MARK: - CIImage Extension

extension CIImage {
    var cgImage: CGImage? {
        let ciContext = CIContext()
        return ciContext.createCGImage(self, from: self.extent)
    }
}
