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
    var rootEntity: AnchorEntity? { get set }
    var onHandDataReceived: (([HandData]) -> Void)? { get set }

    func startTracking()
    func stopTracking()
    func makeHandJointEntities() -> [HandChirality: [HandPart: Entity]]
}

public final class HandTrackingClient: HandTrackingProvider {

    let principal: HandTrackingProvider

    public var rootEntity: AnchorEntity? {
        get { principal.rootEntity }
        set { principal.rootEntity = newValue }
    }

    public init() {
        self.principal = SimulatorHandTrackingProvider(networkingProvider: BonjourNetworkClient())
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
    public func makeHandJointEntities() -> [HandChirality: [HandPart: Entity]] {
        principal.makeHandJointEntities()
    }
}
