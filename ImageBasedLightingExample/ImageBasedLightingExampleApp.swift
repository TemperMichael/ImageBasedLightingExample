//
//  ImageBasedLightingExampleApp.swift
//  ImageBasedLightingExample
//
//  Created by Michael Temper on 10.12.23.
//

import OSLog
import SwiftUI

let logger = Logger(subsystem: "com.example.ImageBasedLightingExample", category: "general")

@main
struct ImageBasedLightingExampleApp: App {

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    init() {
        registerComponentsAndSystems()
    }

    func registerComponentsAndSystems() {
        AnimationComponent.registerComponent()
        AnimationSystem.registerSystem()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                }
        }.windowStyle(.plain).defaultSize(width: 1, height: 0, depth: 0, in: .meters)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(viewModel: ViewModel())
        }.immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
