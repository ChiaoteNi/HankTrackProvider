//
//  GestureAnalyzer.swift
//  HandTrackCapture
//
//  Created by Chiaote Ni on 2024/9/24.
//

import AVFoundation
import Vision
import CoreGraphics
import HandTrackingModels

class GestureAnalyzer: @unchecked Sendable {
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let analysisQueue = DispatchQueue(label: "com.example.GestureAnalysisQueue")

    // Closure to receive the processed HandData
    var onHandDataProcessed: (([HandData]) -> Void)?
    var waitingSampleBuffer: CMSampleBuffer?

    init() {
        handPoseRequest.maximumHandCount = 2
    }

    func analyze(sampleBuffer: CMSampleBuffer) {
        waitingSampleBuffer = sampleBuffer
        analysisQueue.async { [weak self] in
            guard let self, sampleBuffer === self.waitingSampleBuffer else { return }
            let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([self.handPoseRequest])
                guard let observations = self.handPoseRequest.results else { return }
                let handDataArray = self.processHandPoseObservations(observations)
                DispatchQueue.main.async {
                    if sampleBuffer === self.waitingSampleBuffer { 
                        self.waitingSampleBuffer = nil
                    }
                    guard let handDataArray else { return }
                    self.onHandDataProcessed?(handDataArray)
                }
            } catch {
                print("Error performing hand pose request: \(error)")
            }
        }
    }

    private func processHandPoseObservations(_ observations: [VNHumanHandPoseObservation]) -> [HandData]? {
        var handsData = [HandData]()

        for (index, observation) in observations.enumerated() {
            do {
                guard observation.confidence > 0.9 else { return nil }

                let chirality: HandChirality = (index == 0) ? .right : .left
                let fingerJoints = try observation.recognizedPoints(.all)
                let handJoints = convertToHandJoints(from: fingerJoints)
                let handData = HandData(chirality: chirality, joints: handJoints)
                handsData.append(handData)
            } catch {
                print("Error processing observation: \(error)")
            }
        }
        return handsData
    }

    private func convertToHandJoints(from fingerJoints: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> [HandJoint] {
        var joints = [HandJoint]()

        for (jointName, recognizedPoint) in fingerJoints {
            guard recognizedPoint.confidence > 0.6 else { continue }

            let position = SIMD3<Float>(
                Float(recognizedPoint.location.x),
                Float(recognizedPoint.location.y),
                0.0 // z-coordinate can be set to 0 for 2D points
            )

            if let handPart = mapJointNameToHandPart(jointName) {
                let handJoint = HandJoint(position: position, index: handPart.rawValue)
                joints.append(handJoint)
            }
        }
        return joints
    }

    private func mapJointNameToHandPart(_ jointName: VNHumanHandPoseObservation.JointName) -> HandPart? {
        switch jointName {
        case .wrist:
            return .wrist
        case .thumbCMC:
            return .thumbKnuckle
        case .thumbMP:
            return .thumbIntermediateBase
        case .thumbIP:
            return .thumbIntermediateTip
        case .thumbTip:
            return .thumbTip
        case .indexMCP:
            return .indexFingerMetacarpal
        case .indexPIP:
            return .indexFingerKnuckle
        case .indexDIP:
            return .indexFingerIntermediateBase
        case .indexTip:
            return .indexFingerTip
        case .middleMCP:
            return .middleFingerMetacarpal
        case .middlePIP:
            return .middleFingerKnuckle
        case .middleDIP:
            return .middleFingerIntermediateBase
        case .middleTip:
            return .middleFingerTip
        case .ringMCP:
            return .ringFingerMetacarpal
        case .ringPIP:
            return .ringFingerKnuckle
        case .ringDIP:
            return .ringFingerIntermediateBase
        case .ringTip:
            return .ringFingerTip
        case .littleMCP:
            return .littleFingerMetacarpal
        case .littlePIP:
            return .littleFingerKnuckle
        case .littleDIP:
            return .littleFingerIntermediateBase
        case .littleTip:
            return .littleFingerTip
        default:
            return .unknown
        }
    }
}

extension CMSampleBuffer: @unchecked @retroactive Sendable {}
