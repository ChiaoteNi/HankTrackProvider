//
//  SimulatorHandTrackingProvider.swift
//  HandTrackingClient
//
//  Created by Chiaote Ni on 2024/9/20.
//

import Foundation
import RealityKit
import HandTrackingModels

protocol NetworkingProvider: AnyObject {
    var onReceive: ((Data) -> Void)? { get set }

    func start()
    func stop()
}

protocol DevicePositionProvider: AnyObject {
    func retrieveCurrentPosition() -> SIMD3<Float>?
}

final class SimulatorHandTrackingProvider: HandTrackingProvider {

    var onHandDataReceived: (([HandData]) -> Void)? {
        didSet {
            guard let onHandDataReceived, let relocatedHandDatas else { return }
            onHandDataReceived(relocatedHandDatas)
        }
    }

    private let networkingProvider: NetworkingProvider
    private let devicePositionProvider: DevicePositionProvider

    private var devicePosition: SIMD3<Float> {
        devicePositionProvider.retrieveCurrentPosition() ?? SIMD3<Float>(0, 0, -1)
    }

    private var handDatas: [HandData]?
    private var relocatedHandDatas: [HandData]? {
        guard let handDatas else { return nil }
        return relocateHandDatasWithOrigin(handDatas, origin: devicePosition)
    }
    private var handJointEntities: [HandChirality: [HandPart: ModelEntity]] = [:]

    init(networkingProvider: NetworkingProvider, devicePositionProvider: DevicePositionProvider) {
        self.networkingProvider = networkingProvider
        self.devicePositionProvider = devicePositionProvider
    }

    func startTracking() {
        networkingProvider.start()
        networkingProvider.onReceive = { [weak self] data in
            guard let self = self else { return }
            do {
                let handDatas = try JSONDecoder().decode([HandData].self, from: data)
                self.handDatas = handDatas
                if !handJointEntities.isEmpty {
                    Task {
                        await self.updateHandJointEntities(handDatas)
                    }
                }
                if let onHandDataReceived, let relocatedHandDatas {
                    onHandDataReceived(relocatedHandDatas)
                }
            } catch {
                print("Error decoding hand data: \(error)")
            }
        }
    }

    func stopTracking() {
        networkingProvider.stop()
    }

    func makeHandJointEntities(rootEntity: AnchorEntity) -> [HandChirality: [HandPart: Entity]] {
        guard handJointEntities.isEmpty else {
            return handJointEntities
        }
        let leftHandRootEntities = makeHandJoinEntities(handSide: .left, rootEntity: rootEntity)
        let rightHandRootEntities = makeHandJoinEntities(handSide: .right, rootEntity: rootEntity)
        handJointEntities = [
            .left: leftHandRootEntities,
            .right: rightHandRootEntities
        ]
        return handJointEntities
    }
}

// MARK: - Private functions
extension SimulatorHandTrackingProvider {

    private func makeHandJointSphere(location: SIMD3<Float>, color: SimpleMaterial.Color, radius: Float) -> ModelEntity {
        let sphere = ModelEntity(mesh: .generateSphere(radius: radius))
        sphere.model?.materials = [SimpleMaterial(color: color, isMetallic: false)]
        sphere.position = location
        sphere.physicsBody = PhysicsBodyComponent(
            massProperties: .init(mass: 0),
            material: .generate(friction: 0.5, restitution: 0.1),
            mode: .dynamic
        )

        let collisionShape = ShapeResource.generateSphere(radius: radius)
        let collisionComp = CollisionComponent(shapes: [collisionShape])
        sphere.components.set(collisionComp)

        return sphere
    }

    private func relocateHandDatasWithOrigin(_ handDatas: [HandData], origin: SIMD3<Float>) -> [HandData] {
        handDatas.map {
            relocateHandDataWithOrigin($0, origin: origin)
        }
    }

    private func relocateHandDataWithOrigin(_ handData: HandData, origin: SIMD3<Float>) -> HandData {
        let relocatedJoints = handData.joints.map { joint -> HandJoint in
            HandJoint(
                position: SIMD3(
                    x: origin.x - joint.position.x + 0.5,
                    y: origin.y + joint.position.y - 0.5,
                    z: origin.z + joint.position.z - 1
                ),
                index: joint.index
            )
        }
        return HandData(chirality: handData.chirality, joints: relocatedJoints)
    }

    @MainActor
    private func updateHandJointEntities(_ handsData: [HandData]) {
        let isHandsDataEnable = !handsData.isEmpty
        handJointEntities
            .values
            .flatMap { $0.values }
            .forEach { $0.isEnabled = isHandsDataEnable }

        let devicePosition = devicePosition
        handsData.forEach {
            let handData = relocateHandDataWithOrigin($0, origin: devicePosition)
            let handSide = handData.chirality
            let jointEntities = handJointEntities[handSide]
            handData.joints.forEach { joint in
                let handPart = joint.handPart
                let model = jointEntities?[handPart]
                model?.position = joint.position
            }
        }
    }

    private func makeHandJoinEntities(handSide: HandChirality, rootEntity: Entity) -> [HandPart: ModelEntity] {
        var jointEntities: [HandPart: ModelEntity] = [:]
        HandPart.allCases.forEach { handPart in
            let model = makeHandJointSphere(
                location: .zero,
                color: handSide == .left ? .white : .red,
                radius: handPart == .handWrist ? 0.05 : 0.01
            )
            jointEntities[handPart] = model
            rootEntity.addChild(model)
        }
        return jointEntities
    }
}
