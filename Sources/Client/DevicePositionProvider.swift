//
//  DevicePositionProvider.swift
//  HandTrackingClient
//
//  Created by Chiaote Ni on 2024/9/21.
//

import Foundation
import ARKit
import RealityKit

#if os(visionOS)
final class ARKitDevicePositionProvider: DevicePositionProvider {
    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()

    init() {
        Task {
            try? await session.run([worldTracking])
        }
    }

    func retrieveCurrentPosition() -> SIMD3<Float>? {
        let anchor = self.worldTracking.queryDeviceAnchor(atTimestamp: Date().timeIntervalSince1970)
        guard let transform = anchor?.originFromAnchorTransform.columns.3 else { return nil }
        return SIMD3(
            transform.x,
            transform.y,
            transform.z
        )
    }

    func start() {
    }

    func stop() {
//        session.stop()
    }
}
#endif
