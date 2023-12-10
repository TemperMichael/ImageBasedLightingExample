//
//  Animationsystem.swift
//  ImageBasedLightingExample
//
//  Created by Michael Temper on 10.12.23.
//

import Foundation
import RealityKit

// Thanks to arthurschiller for this AnimationSystem!
// Source: https://gist.github.com/arthurschiller/f299b5aa002db0caabd45418858b6642

// Custom Animation System
class AnimationSystem: System {
    private static let query = EntityQuery(
        where: .has(AnimationComponent.self)
    )

    required init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let animationEntites = context.scene.performQuery(Self.query)

        for entity in animationEntites {
            if let animationComponent = entity.components[AnimationComponent.self] {
                animationComponent.onUpdate()
            }
        }
    }
}

// Custom Animation Component
struct AnimationComponent: Component {
    let bindableValueIdentifier: String
    let onUpdate: (() -> Void)

    init(
        bindableValueIdentifier: String,
        onUpdate: @escaping (() -> Void)
    ) {
        self.bindableValueIdentifier = bindableValueIdentifier
        self.onUpdate = onUpdate
    }
}

// Bindable Value Animations
extension Entity {
    func animateBindableValue<Value: AnimatableData>(
        from: Value,
        to: Value,
        duration: TimeInterval,
        delay: TimeInterval,
        timing: AnimationTimingFunction,
        identifier: String,
        withScene scene: RealityKit.Scene,
        onAnimationFrame: @escaping () -> Void,
        onCompletion: (() -> Void)?
    ) {
        components.set(
            AnimationComponent(
                bindableValueIdentifier: identifier,
                onUpdate: {
                    onAnimationFrame()
                }
            )
        )

        let animationDefinition = FromToByAnimation(
            name: identifier,
            from: from,
            to: to,
            duration: duration,
            timing: timing,
            bindTarget: .parameter(identifier), // set custom binding target
            delay: delay
        )

        if let animation = try? AnimationResource.generate(with: animationDefinition) {
            playAnimation(animation)

            scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: self) { [weak self] event in
                onCompletion?()

                self?.components.remove(AnimationComponent.self)
            }
            .storeWhileEntityActive(self)
        }
    }

    func animateFloatValue(
        from: Float,
        to: Float,
        duration: TimeInterval,
        delay: TimeInterval = 0,
        timing: AnimationTimingFunction = .easeIn,
        identifier: String = UUID().uuidString,
        withScene scene: RealityKit.Scene,
        onAnimationFrame: @escaping (Float, Entity?) -> Void,
        onCompletion: ((Entity?) -> Void)? = nil
    ) {
        parameters[identifier] = BindableValue<Float>(from)
        animateBindableValue(
            from: from,
            to: to,
            duration: duration,
            delay: delay,
            timing: timing,
            identifier: identifier,
            withScene: scene,
            onAnimationFrame: { [weak self] in
                if let bindableValue = self?.bindableValues[.parameter(identifier), Float.self] {
                    onAnimationFrame(bindableValue.value, self)
                }
            },
            onCompletion: { [weak self] in
                onAnimationFrame(to, self)
                onCompletion?(self)
            }
        )
    }
}
