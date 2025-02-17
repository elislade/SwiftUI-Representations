import SceneKitRepresentations


struct SceneKitExample: View {
    
    @State private var cameraControls = false
    @State private var options: SCNDebugOptions = []
    
    private func binding(for options: SCNDebugOptions) -> Binding<Bool> {
        .init(
            get: { self.options.contains(options) },
            set: {
                if $0 {
                    self.options.insert(options)
                } else {
                    self.options.remove(options)
                }
            }
        )
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            SCNViewRepresentation(
                scene: .sphereExample,
                debugOptions: options,
                allowsCameraControl: cameraControls
            )
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0){
                    Toggle(isOn: $cameraControls){
                        Text("Camera Controls").font(.headline)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .renderAsWireframe)){
                        Text("Wireframe").font(.headline)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .showBoundingBoxes)){
                        Text("Bounding Boxes").font(.headline)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .showLightExtents)){
                        Text("Light Extents").font(.headline)
                    }
                    .padding()
                    
                    Divider()
                }
            }
        }
        .preferredColorScheme(.dark)
        .background(
            LinearGradient(
                colors: [Color(white: 0.15), Color(white: 0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
}

extension SCNScene {
    
    static let sphereExample: SCNScene = {
        let scene = SCNScene()
        
        let geometryNode = SCNNode(geometry: SCNSphere(radius: 1))
        geometryNode.opacity = 0
        geometryNode.position = .init(x: -2, y: -1, z: -1)
        geometryNode.geometry?.materials = [ {
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = CGColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
            material.metalness.contents = 0.5
            material.roughness.contents = 0.6
            material.specular.contents = 1
            return material
        }() ]
        geometryNode.runAction(.jiggle())
        geometryNode.runAction({
            let action = SCNAction.group([
                .fadeIn(duration: 2),
                .move(to: SCNVector3(x: -2, y: -1, z: -1), duration: 4)
            ])
            action.timingMode = .easeInEaseOut
            return action
        }())
        
        
        let lookAtGeometry = SCNLookAtConstraint(target: geometryNode)
        
        let backlightNode = SCNNode()
        backlightNode.position = .init(x: 0, y: 5, z: -20)
        backlightNode.constraints = [lookAtGeometry]
        backlightNode.light = {
            let light = SCNLight()
            light.type = .area
            light.drawsArea = false
            light.areaExtents.x = 120
            light.areaExtents.y = 20
            light.castsShadow = true
            light.intensity = 2000
            return light
        }()
        
        
        let lightNode = SCNNode()
        lightNode.position = .init(x: 0, y: -5, z: -10)
        lightNode.constraints = [lookAtGeometry]
        lightNode.light = {
            let light = SCNLight()
            light.castsShadow = true
            light.type = .spot
            light.spotOuterAngle = 80
            return light
        }()
        lightNode.runAction({
            let action = SCNAction.moveBy(x: 0, y: 60, z: 40, duration: 10)
            action.timingMode = .easeInEaseOut
            return action
        }())
        
        scene.rootNode.addChildNode(geometryNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(backlightNode)
        
        return scene
    }()
    
}

extension SCNAction {
    
    static func jiggle() -> SCNAction {
        func adjust(_ key: ReferenceWritableKeyPath<SCNNode, SCNFloat>, isReversed: Bool = false) -> SCNAction {
            let duration = TimeInterval.random(in: 1...3)
            let action = SCNAction.customAction(duration: duration){ node, value in
                let fraction = value / duration
                node[keyPath: key] = 1 + (sin(SCNFloat(fraction * 2 * .pi)) / 16)
            }
            return .repeatForever(action)
        }
        
        return .group([
            adjust(\.scale.x), adjust(\.scale.y), adjust(\.scale.z)
        ])
    }
    
}

#Preview("SceneKit Example") {
    SceneKitExample()
    #if os(macOS)
        .frame(width: 320, height: 480)
    #endif
}
