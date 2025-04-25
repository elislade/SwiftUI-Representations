import Foundation
import AVKitRepresentations


struct AVKitExample: View  {
    
    @StateObject var player = AVPlayerObservable(url: .eliSladeProfilePosesVideo)
    
    @State private var time: Double = 0
    @State private var duration: Double = 0.1
    
    
    private var timeBandit: Binding<Double> {
        .init(
            get: { time },
            set: { player.seek(to: $0) }
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let item = player.currentItem {
                ZStack {
                    Color.clear
                    
                    if player.status == .readyToPlay {
                        AVPlayerViewRepresentation(player)
                            .onReceive(item.publisher(for: \.duration)){
                                if !$0.isIndefinite {
                                    duration = $0.seconds
                                }
                            }
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                Divider()
                
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Text("Timecode")
                                .font(.headline)
                            
                            Text(timeBandit.wrappedValue, format: .number.rounded(increment: 0.01))

                            Spacer()
                            
                            Text(duration, format: .number.rounded(increment: 0.01))
                                .opacity(0.5)
                            
                            Button(player.rate == 0 ? "Play" : "Pause", systemImage: player.rate == 0 ? "play" : "pause"){
                                player.rate = player.rate == 0 ? 1 : 0
                            }
                            .font(.title)
                            .disabled(timeBandit.wrappedValue == duration)
                            
                            Button("Reset", systemImage: "arrow.counterclockwise"){
                                timeBandit.wrappedValue = 0
                            }
                            .font(.title)
                            .disabled(timeBandit.wrappedValue == 0)
                        }
                        .labelStyle(.iconOnly)
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.hierarchical)
                        
                        Slider(
                            value: timeBandit,
                            in: 0...duration
                        )
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack {
                        HStack {
                            Text("Volume").font(.headline)
                            Spacer()
                            Text(player.volume, format: .number.rounded(increment: 0.1))
                        }
                        
                        Slider(value: $player.volume, in: 0...1)
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack {
                        HStack {
                            Text("Speed").font(.headline)
                            Spacer()
                            Text(player.rate, format: .number.rounded(increment: 0.1))
                        }
                        
                        Slider(value: $player.rate, in: 0...10)
                            .disabled(timeBandit.wrappedValue == duration)
                    }
                    .padding()
                       
                }
                .monospacedDigit()
                .task {
                    for await time in player.timeStream(atInterval: 0.01) {
                        self.time = time
                    }
                }
                .animation(.smooth, value: player.rate)
            }
        }
        .animation(.bouncy, value: player.status)
    }
    
}


#Preview("AVKit Example"){
    AVKitExample()
}
