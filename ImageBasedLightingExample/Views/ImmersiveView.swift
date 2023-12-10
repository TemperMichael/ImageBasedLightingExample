//
//  ImmersiveView.swift
//  ImageBasedLightingExample
//
//  Created by Michael Temper on 10.12.23.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {

    @Environment(\.realityKitScene) var scene: RealityKit.Scene?
    @Bindable var viewModel: ViewModel

    var body: some View {
        RealityView { content, attachments in
            await viewModel.setupEnvironmentResources()
            await viewModel.setupEntities()
            content.add(viewModel.root)

            if let uiAttachment = attachments.entity(for: "UI") {
                uiAttachment.position.y = 1.35
                uiAttachment.position.z -= 0.9
                content.add(uiAttachment)
            }
        } attachments: {
            Attachment(id: "UI") {
                uiView
            }
        }
        .onChange(of: viewModel.blendFactor) {
            viewModel.updateBlending()
        }
        .onChange(of: viewModel.intensity) {
            viewModel.updateIntensity()
        }
    }

    var uiView: some View {
        VStack {
            HStack {
                Text("Current")
                Slider(value: $viewModel.blendFactor, in: 0...1)
                    .padding()
                Text("Next")
            }

            HStack {
                Text("Intensity")
                Slider(value: $viewModel.intensity, in: 0...20)
                    .padding()
                Text(String(format: "%.1f", viewModel.intensity))
                    .frame(width: 40)
            }

            Button {
                guard let scene else {
                    logger.error("Scene not found!")
                    return
                }

                viewModel.blendLighting(in: scene)
            } label: {
                Text("Change Light Animated")
            }
        }
        .padding()
        .glassBackgroundEffect()
        .frame(width: 400)
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}
