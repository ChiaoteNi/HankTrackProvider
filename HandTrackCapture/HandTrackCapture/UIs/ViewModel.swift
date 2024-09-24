//
//  ViewModel.swift
//  HandTrackCapture
//
//  Created by Chiaote Ni on 2024/9/24.
//

import SwiftUI
import Combine
import Observation
import HandTrackingModels

@Observable
class HandTrackingViewModel {
    let videoCaptureHandler = VideoCaptureHandler()
    private let gestureAnalyzer = GestureAnalyzer()
    private let dataSender = DataSender()

    var handDataForPreview: [HandData] = []

    func setup() {
        // Set the sample buffer callback to analyze gestures
        videoCaptureHandler.setSampleBufferCallback { [weak self] sampleBuffer in
            self?.gestureAnalyzer.analyze(sampleBuffer: sampleBuffer)
        }

        // Setup GestureAnalyzer to send data when processed
        gestureAnalyzer.onHandDataProcessed = { [weak self] handDataArray in
            guard let self else { return }
            self.handDataForPreview = self.convertYAxisForPreview(handDataArray)
            self.dataSender.send(data: handDataArray)
        }
    }

    func teardown() {
        // Stop the capture session if needed
        videoCaptureHandler.captureSession.stopRunning()
    }

    private func convertYAxisForPreview(_ handDatas: [HandData]) -> [HandData] {
        handDatas.map { handData in
            HandData(
                chirality: handData.chirality,
                joints: handData.joints.map { joint in
                    let position = SIMD3<Float>(
                        joint.position.x,
                        1 - joint.position.y,
                        joint.position.z
                    )
                    return HandJoint(position: position, index: joint.index)
                })
        }
    }
}
