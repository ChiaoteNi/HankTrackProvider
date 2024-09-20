//
//  SimulatorHandTrackingProvider.swift
//  HandTrackingClient
//
//  Created by Chiaote Ni on 2024/9/20.
//

import Foundation
import RealityKit
import Models

protocol NetworkingProvider: AnyObject {
    var onReceive: ((Data) -> Void)? { get set }

    func start()
    func stop()
}

final class SimulatorHandTrackingProvider: HandTrackingProvider {

    var onHandDataReceived: (([HandData]) -> Void)? {
        didSet {
            guard let onHandDataReceived, let relocatedHandDatas else { return }
            onHandDataReceived(relocatedHandDatas)
        }
    }

    private let networkingProvider: NetworkingProvider

    private var handDatas: [HandData]?
    private let rootEntity: AnchorEntity
    private var relocatedHandDatas: [HandData]? {
        guard let handDatas else { return nil }
        return relocateHandDataWithOrigin(
            handDatas,
            origin: rootEntity.position
        )
    }
    private var handJointEntities: [Chirality: [HandPart: ModelEntity]] = [:]

    init(networkingProvider: NetworkingProvider, rootEntity: AnchorEntity) {
        self.networkingProvider = networkingProvider
        self.rootEntity = rootEntity
    }

    func startTracking() {
        networkingProvider.start()
        networkingProvider.onReceive = { [weak self] data in
            guard let self = self else { return }
            do {
                let handDatas = try JSONDecoder().decode([HandData].self, from: data)
                self.handDatas = handDatas
                if !handJointEntities.isEmpty {
                    self.updateHandJointEntities(handDatas)
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

    func makeHandJointEntities() -> [Chirality: [HandPart: Entity]] {
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
        sphere.physicsBody = PhysicsBodyComponent(massProperties: .init(mass: 0), material: .generate(friction: 0.5, restitution: 0.1), mode: .dynamic)

        let collisionShape = ShapeResource.generateSphere(radius: radius)
        let collisionComp = CollisionComponent(shapes: [collisionShape])
        sphere.components.set(collisionComp)

        return sphere
    }

    private func relocateHandDataWithOrigin(_ handDatas: [HandData], origin: SIMD3<Float>) -> [HandData] {
        handDatas.map { handData -> HandData in
            let relocatedJoints = handData.joints.map { joint -> HandJoint in
                HandJoint(
                    position: SIMD3(
                        x: joint.position.x + origin.x,
                        y: joint.position.y + origin.y,
                        z: joint.position.z + origin.z
                    ),
                    index: joint.index
                )
            }
            return HandData(chirality: handData.chirality, joints: relocatedJoints)
        }
    }

    private func updateHandJointEntities(_ handsData: [HandData]) {
        handsData.forEach { handData in
            let handSide = handData.chirality
            let jointEntities = handJointEntities[handSide]
            handData.joints.forEach { joint in
                let handPart = joint.handPart
                let model = jointEntities?[handPart]
                model?.position = joint.position
            }
        }
    }

    private func makeHandJoinEntities(handSide: Chirality, rootEntity: Entity) -> [HandPart: ModelEntity] {
        var jointEntities: [HandPart: ModelEntity] = [:]
        HandPart.allCases.forEach { handPart in
            let model = makeHandJointSphere(
                location: .zero,
                color: handSide == .left ? .white : .clear,
                radius: 0.03
            )
            jointEntities[handPart] = model
            model.setParent(rootEntity)
        }
        return jointEntities
    }
}
