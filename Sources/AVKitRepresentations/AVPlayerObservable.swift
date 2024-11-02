import Combine
import AVKit


public class AVPlayerObservable: AVPlayer, ObservableObject {
    
    private var bag: Set<AnyCancellable> = []
    
    public override init() {
        super.init()
        listenForNotifications()
    }
    
    public override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
    }
    
    public override init(url URL: URL) {
        super.init(url: URL)
    }
    
    private func listenForNotifications() {
        publisher(for: \.reasonForWaitingToPlay).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.timeControlStatus).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.error).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.status).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.currentItem).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
    }
    
    public override var isMuted: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var volume: Float {
        willSet { objectWillChange.send() }
    }
    
    public override var rate: Float {
        willSet { objectWillChange.send() }
    }
    
    public override var defaultRate: Float {
        willSet { objectWillChange.send() }
    }
    
    public override var actionAtItemEnd: AVPlayer.ActionAtItemEnd {
        willSet { objectWillChange.send() }
    }
    
    public override var automaticallyWaitsToMinimizeStalling: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var allowsExternalPlayback: Bool {
        willSet { objectWillChange.send() }
    }
    
    public func timeStream(atInterval interval: TimeInterval) -> AsyncStream<Double> {
        AsyncStream { [unowned self] continuation in
            let observer = addPeriodicTimeObserver(
                forInterval: CMTime(seconds: interval, preferredTimescale: CMTimeScale(kCMTimeMaxTimescale)),
                queue: nil
            ){ time in
                if time.isValid {
                    continuation.yield(Double(time.seconds))
                }
            }
            
            continuation.onTermination = { [unowned self] _ in
                removeTimeObserver(observer)
            }
        }
    }
    
}
