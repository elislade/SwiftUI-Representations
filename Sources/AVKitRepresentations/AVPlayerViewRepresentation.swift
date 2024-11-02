import SwiftUI
import AVKit

protocol PlayerBackedView: AnyObject {
    var player: AVPlayer? { get set }
}

public struct AVPlayerViewRepresentation {
    
    let player: AVPlayer
    
    public init(_ player: AVPlayer) {
        self.player = player
    }
    
    private func sync(view: any PlayerBackedView){
        if view.player != player {
            view.player = player
        }
    }
    
}

#if canImport(UIKit)

public final class AVPlayerLayerView: UIView, PlayerBackedView {
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    public override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    var aspectRatio: CGFloat? {
        layer.sublayers?[0].sublayers?[0].bounds.size.aspect
    }
    
    init(player: AVPlayer? = nil) {
        super.init(frame: .zero)
        self.player = player
        self.playerLayer.videoGravity = .resizeAspect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AVPlayerViewRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> AVPlayerLayerView {
        AVPlayerLayerView(player: player)
    }
    
    public func updateUIView(_ uiView: AVPlayerLayerView, context: Context) {
        sync(view: uiView)
    }
    
}

#elseif canImport(AppKit)

public final class AVPlayerLayerView: NSView, PlayerBackedView {
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    init(player: AVPlayer? = nil) {
        super.init(frame: .zero)
        self.layer = AVPlayerLayer(player: player)
        self.wantsLayer = true
        self.playerLayer.videoGravity = .resizeAspect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AVPlayerViewRepresentation: NSViewRepresentable {
    public func makeNSView(context: Context) -> AVPlayerLayerView {
        AVPlayerLayerView(player: player)
    }
    
    public func updateNSView(_ nsView: AVPlayerLayerView, context: Context) {
        sync(view: nsView)
    }
}

#endif

public extension CGSize {
    var aspect: CGFloat { width / height }
}
