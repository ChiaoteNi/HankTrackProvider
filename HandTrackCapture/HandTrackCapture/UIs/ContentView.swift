//
//  ContentView.swift
//  HandTrackCapture
//
//  Created by Chiaote Ni on 2024/9/24.
//

import SwiftUI

struct ContentView: View {
    @State
    private var viewModel = HandTrackingViewModel()

    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(captureSession: viewModel.videoCaptureHandler.captureSession)
                .edgesIgnoringSafeArea(.all)

            // Hand Overlay
            HandOverlay(handData: viewModel.handDataForPreview)
        }
        .onAppear {
            viewModel.setup()
        }
        .onDisappear {
            viewModel.teardown()
        }
    }
}
