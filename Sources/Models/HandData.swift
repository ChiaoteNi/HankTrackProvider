//
//  HandData.swift
//
//
//  Created by Chiaote Ni on 2024/9/20.
//

import Foundation

public struct HandData: Codable {
    public var chirality: Chirality
    public var joints: [HandJoint]

    public init(chirality: Chirality, joints: [HandJoint]) {
        self.chirality = chirality
        self.joints = joints
    }
}

public enum Chirality: Codable {
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
    case handWrist
    case handThumbKnuckle
    case handThumbIntermediateBase
    case handThumbIntermediateTip
    case handThumbTip
    case handIndexFingerMetacarpal
    case handIndexFingerKnuckle
    case handIndexFingerIntermediateBase
    case handIndexFingerIntermediateTip
    case handIndexFingerTip
    case handMiddleFingerMetacarpal
    case handMiddleFingerKnuckle
    case handMiddleFingerIntermediateBase
    case handMiddleFingerIntermediateTip
    case handMiddleFingerTip
    case handRingFingerMetacarpal
    case handRingFingerKnuckle
    case handRingFingerIntermediateBase
    case handRingFingerIntermediateTip
    case handRingFingerTip
    case handLittleFingerMetacarpal
    case handLittleFingerKnuckle
    case handLittleFingerIntermediateBase
    case handLittleFingerIntermediateTip
    case handLittleFingerTip
    case handForearmWrist
    case handForearmArm
    case unknown = -1
}
