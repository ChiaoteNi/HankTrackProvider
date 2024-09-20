//
//  HandTrackingClient.swift
//
//
//  Created by Chiaote Ni on 2024/9/20.
//

import Foundation
import RealityKit
import Models

protocol HandTrackingProvider: AnyObject {
    var onHandDataReceived: (([HandData]) -> Void)? { get set }

    func startTracking()
    func stopTracking()
    func makeHandJointEntities() -> [Chirality: [HandPart: Entity]]
}

public final class HandTrackingClient: HandTrackingProvider {

    let principal: HandTrackingProvider

    public init(rootEntity: AnchorEntity) {
        self.principal = SimulatorHandTrackingProvider(
            networkingProvider: BonjourNetworkClient(),
            rootEntity: rootEntity
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
    public func makeHandJointEntities() -> [Chirality: [HandPart: Entity]] {
        principal.makeHandJointEntities()
    }
}
