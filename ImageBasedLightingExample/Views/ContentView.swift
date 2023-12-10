//
//  ContentView.swift
//  ImageBasedLightingExample
//
//  Created by Michael Temper on 10.12.23.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        Text("""
            This example shows how image based lighting works in visionOS.

            Also make sure to check out how the ImmersionStyle affects the lighting!

            The surrounding skybox also has a ImaseBasedLightComponent set, if it looks like the light on the other entities comes from the skybox, this is not the case.
            It also works without the surrounding skybox.
            """)
        .multilineTextAlignment(.center)
        .padding()
        .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
