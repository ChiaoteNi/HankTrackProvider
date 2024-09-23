//
//  BonjourNetworkService.swift
//  HandTrackingClient
//
//  Created by Chiaote Ni on 2024/9/20.
//

import Foundation

public final class BonjourNetworkClient {

    public var onReceive: ((Data) -> Void)?

    let session = BonjourSession(configuration: .default)

    public init() {
        session.onReceive = { data, peer in
            self.onReceive?(data)
        }
    }

    public func start() {
        session.start()
    }

    public func stop() {
        session.stop()
    }
}

public final class BonjourDataSender {

    let session = BonjourSession(configuration: .default)

    deinit {
        session.stop()
    }
    public init() {
        session.start()
    }

    public func send(_ data: Data) {
        session.broadcast(data)
    }
}
