//
//  BonjourNetworkService.swift
//  HandTrackingClient
//
//  Created by Chiaote Ni on 2024/9/20.
//

import Foundation

final class BonjourNetworkClient: NetworkingProvider {

    var onReceive: ((Data) -> Void)?

    let session = BonjourSession(configuration: .default)

    init() {
        session.onReceive = { data, peer in
            self.onReceive?(data)
        }
    }

    func start() {
        session.start()
    }

    func stop() {
        session.stop()
    }
}
