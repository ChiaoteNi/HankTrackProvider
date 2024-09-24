//
//  CameraPreview.swift
//  HandTrackCapture
//
//  Created by Chiaote Ni on 2024/9/24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: NSViewRepresentable {
    class VideoPreviewView: NSView {
        var previewLayer: AVCaptureVideoPreviewLayer?

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }

        required init?(coder decoder: NSCoder) {
            super.init(coder: decoder)
            wantsLayer = true
        }

        func setSession(_ session: AVCaptureSession) {
            previewLayer?.removeFromSuperlayer()
            let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            newPreviewLayer.videoGravity = .resizeAspectFill
            newPreviewLayer.frame = self.bounds
            layer?.addSublayer(newPreviewLayer)
            previewLayer = newPreviewLayer
        }

        override func layout() {
            super.layout()
            previewLayer?.frame = self.bounds
        }
    }

    var captureSession: AVCaptureSession

    func makeNSView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.setSession(captureSession)
        return view
    }

    func updateNSView(_ nsView: VideoPreviewView, context: Context) {
        nsView.setSession(captureSession)
    }
}
