//
//  ViewModel.swift
//  ImageBasedLightingExample
//
//  Created by Michael Temper on 10.12.23.
//

import RealityKit
import RealityKitContent
import SwiftUI

@Observable
class ViewModel {

    var currentResource: EnvironmentResource?
    var nextResource: EnvironmentResource?

    var blendFactor: Float = 0
    var intensity: Float = 1

    var root = Entity()

    var entities: [Entity] = [
        ModelEntity(mesh: .generateBox(size: 0.1), materials: [SimpleMaterial(color: .white, roughness: 1, isMetallic: false)]),
        ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .white, roughness: 0, isMetallic: false)]),
        ModelEntity(mesh: .generateSphere(radius: 100), materials: [SimpleMaterial(color: .white, isMetallic: false)])
    ]

    func setupEnvironmentResources() async {
        do {
            currentResource = try await EnvironmentResource(named: "Skybox_Yellow")
            nextResource = try await EnvironmentResource(named: "Skybox_Green")
        } catch {
            logger.error("Could not load resource: \(error.localizedDescription)")
        }
    }

    func setupEntities() async {
        do {
            let robot = try await Entity(named: "robot", in: realityKitContentBundle)
            entities.append(robot)

            for animations in await robot.availableAnimations {
                await robot.playAnimation(animations.repeat(duration: .infinity),
                                          transitionDuration: 1.25,
                                          startsPaused: false)
            }
        } catch {
            logger.error("Could not load model named: \(error.localizedDescription)")
        }

        guard let currentResource, let nextResource else {
            logger.error("EnvironmentResources not setup correctly!")
            return
        }

        let iblComponent = ImageBasedLightComponent(source: .blend(currentResource,
                                                                   nextResource,
                                                                   blendFactor),
                                                    intensityExponent: intensity)

        Task { @MainActor in
            // Invert the skybox to show the material on the inside
            entities[2].scale.x = -1

            entities[0].position = [-0.4, 1.8, -1]
            entities[1].position = [0, 1.8, -1]
            entities[3].position = [0.4, 1.68, -1]

            entities.forEach({
                $0.components.set(iblComponent)
                $0.components.set(ImageBasedLightReceiverComponent(imageBasedLight: $0))
                root.addChild($0)
            })
        }
    }

    func updateIntensity() {
        entities.forEach {
            $0.components[ImageBasedLightComponent.self]?.intensityExponent = intensity
        }
    }

    func updateBlending() {
        guard let currentResource, let nextResource else {
            logger.error("EnvironmentResources not found!")
            return
        }

        entities.forEach {
            $0.components[ImageBasedLightComponent.self]?.source = .blend(currentResource, nextResource, blendFactor)
        }
    }

    func blendLighting(in scene: RealityKit.Scene) {
        entities.forEach({
            $0.animateFloatValue(
                from: blendFactor,
                to: blendFactor < 1 ? 1 : 0,
                duration: 1,
                delay: 0,
                timing: .easeInOut,
                withScene: scene,
                onAnimationFrame: { value, entity in
                    guard let entity,
                          let currentResource = self.currentResource,
                          let nextResource = self.nextResource else {
                        logger.error("Could not animate blending!")
                        return
                    }

                    let iblComponent = ImageBasedLightComponent(source: .blend(currentResource,
                                                                               nextResource,
                                                                               value),
                                                                intensityExponent: self.intensity)

                    entity.components.set(iblComponent)

                    self.blendFactor = value
                })
        })
    }
}
