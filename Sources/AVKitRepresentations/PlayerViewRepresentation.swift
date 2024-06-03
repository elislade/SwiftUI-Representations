import SwiftUI
import AVKit

protocol PlayerBackedView: AnyObject {
    var player: AVPlayer? { get set }
}

public struct PlayerViewRepresentation {
    
    let player: AVPlayer
    
    public init(_ player: AVPlayer) {
        self.player = player
    }
    
    private func sync(view: any PlayerBackedView){
        view.player = player
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

extension PlayerViewRepresentation: UIViewRepresentable {
    
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
        self.playerLayer.videoGravity = .resizeAspect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PlayerViewRepresentation: NSViewRepresentable {
    public func makeNSView(context: Context) -> AVPlayerLayerView {
        AVPlayerLayerView(player: player)
    }
    
    public func updateNSView(_ nsView: AVPlayerLayerView, context: Context) {
        sync(view: nsView)
    }
}

#endif

extension CGSize {
    var aspect: CGFloat { width / height }
}

private extension URL {
    
    static let testRemoteVideo = URL(string: "https://elislade.com/assets/images/ProfilePoses.mp4")!
    static let testRemoteVideoB = URL(string:"https://elislade.com/assets/HeroSample.mp4")!
    
}

private struct TestView: View  {
    
    @State private var player = AVPlayer(url: .testRemoteVideoB)

    var body: some View {
        ZStack {
            PlayerViewRepresentation(player)
                .aspectRatio(16/9, contentMode: .fill)

            Button("Play", action: player.play)
        }
    }
    
}

#Preview{
    TestView().edgesIgnoringSafeArea(.all)
}
