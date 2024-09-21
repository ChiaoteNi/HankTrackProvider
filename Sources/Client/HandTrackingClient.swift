//
//  HandTrackingClient.swift
//
//
//  Created by Chiaote Ni on 2024/9/20.
//

import Foundation
import RealityKit
import HandTrackingModels

protocol HandTrackingProvider: AnyObject {
    var onHandDataReceived: (([HandData]) -> Void)? { get set }

    func startTracking()
    func stopTracking()
    func makeHandJointEntities(rootEntity: AnchorEntity) -> [HandChirality: [HandPart: Entity]]
}

public final class HandTrackingClient: HandTrackingProvider {

    let principal: HandTrackingProvider

    public init() {
        self.principal = SimulatorHandTrackingProvider(
            networkingProvider: BonjourNetworkClient(),
            devicePositionProvider: ARKitDevicePositionProvider()
        )
    }

    public var onHandDataReceived: (([HandData]) -> Void)? {
        get { principal.onHandDataReceived }
        set { principal.onHandDataReceived = newValue }
    }

    public func startTracking() {
        principal.startTracking()
    }
    public func stopTracking() {
        principal.stopTracking()
    }
    public func makeHandJointEntities(rootEntity: AnchorEntity) -> [HandChirality: [HandPart: Entity]] {
        principal.makeHandJointEntities(rootEntity: rootEntity)
    }
}
