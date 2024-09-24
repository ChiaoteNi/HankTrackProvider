//
//  HandOverlay.swift
//  HandTrackCapture
//
//  Created by Chiaote Ni on 2024/9/24.
//

import SwiftUI
import HandTrackingModels

struct HandOverlay: View {
    let handData: [HandData]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(handData.indices, id: \.self) { handIndex in
                    let hand = handData[handIndex]
                    ForEach(hand.joints.indices, id: \.self) { jointIndex in
                        let joint = hand.joints[jointIndex]
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .position(x: CGFloat(joint.position.x) * geometry.size.width,
                                      y: CGFloat(joint.position.y) * geometry.size.height)
                    }
                }
            }
        }
    }
}
