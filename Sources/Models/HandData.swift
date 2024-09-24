//
//  HandData.swift
//
//
//  Created by Chiaote Ni on 2024/9/20.
//

import Foundation

public struct HandData: Codable {
    public var chirality: HandChirality
    public var joints: [HandJoint]

    public init(chirality: HandChirality, joints: [HandJoint]) {
        self.chirality = chirality
        self.joints = joints
    }
}

public enum HandChirality: Codable {
    case left
    case right
}

public struct HandJoint: Codable {
    public var position: SIMD3<Float>
    public var index: Int
    public var handPart: HandPart {
        HandPart(rawValue: index) ?? .unknown
    }

    public init(position: SIMD3<Float>, index: Int) {
        self.position = position
        self.index = index
    }
}

public enum HandPart: Int, CaseIterable {
    case wrist
    case thumbKnuckle
    case thumbIntermediateBase
    case thumbIntermediateTip
    case thumbTip
    case indexFingerMetacarpal
    case indexFingerKnuckle
    case indexFingerIntermediateBase
    case indexFingerIntermediateTip
    case indexFingerTip
    case middleFingerMetacarpal
    case middleFingerKnuckle
    case middleFingerIntermediateBase
    case middleFingerIntermediateTip
    case middleFingerTip
    case ringFingerMetacarpal
    case ringFingerKnuckle
    case ringFingerIntermediateBase
    case ringFingerIntermediateTip
    case ringFingerTip
    case littleFingerMetacarpal
    case littleFingerKnuckle
    case littleFingerIntermediateBase
    case littleFingerIntermediateTip
    case littleFingerTip
    case forearmWrist
    case forearmArm
    case unknown = -1
}
