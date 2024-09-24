//
//  DataSender.swift
//  HandTrackCapture
//
//  Created by Chiaote Ni on 2024/9/24.
//

import Foundation
import HandTrackingModels
import HandTrackingNetworking

final class DataSender {

    let bonjourService = BonjourDataSender()

    func send(data: [HandData]) {
        do {
            let data = try JSONEncoder().encode(data)
            bonjourService.send(data)
        } catch {
            assertionFailure("Failed to encode data: \(error)")
        }
    }
}
