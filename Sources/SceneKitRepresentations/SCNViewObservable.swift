import SceneKit


public final class SCNViewObservable: SCNView, ObservableObject {
    
    public override var scene: SCNScene? {
        willSet { objectWillChange.send() }
    }
    
    public override var rendersContinuously: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var allowsCameraControl: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var preferredFramesPerSecond: Int {
        willSet { objectWillChange.send() }
    }
    
    public override var sceneTime: TimeInterval {
        willSet { objectWillChange.send() }
    }
    
    public override var loops: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var pointOfView: SCNNode? {
        willSet { objectWillChange.send() }
    }
    
    public override var antialiasingMode: SCNAntialiasingMode {
        willSet { objectWillChange.send() }
    }
    
    public override var autoenablesDefaultLighting: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var isTemporalAntialiasingEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var isJitteringEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var showsStatistics: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var debugOptions: SCNDebugOptions {
        willSet { objectWillChange.send() }
    }
    
    public override func play(_ sender: Any?) {
        objectWillChange.send()
        super.play(sender)
    }
    
    public override func pause(_ sender: Any?) {
        objectWillChange.send()
        super.pause(sender)
    }
    
    public override func stop(_ sender: Any?) {
        objectWillChange.send()
        super.stop(sender)
    }
    
}
