import Foundation
import AVKitRepresentations


struct AVKitExample: View  {
    
    @ObservedObject var player: AVPlayerObservable
    @State private var time: Double = 0
    
    private var timeBandit: Binding<Double> {
        .init(get: { time }, set: { _time in
            player.seek(to: CMTime(seconds: _time, preferredTimescale: 1000))
        })
    }
    
    var body: some View {
        VStack {
            if let item = player.currentItem {
                
                ZStack {
                    Color.clear
                    
                    if player.status == .readyToPlay {
                        AVPlayerViewRepresentation(player)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    } else {
                        Rectangle()
                            .aspectRatio(16/9, contentMode: .fit)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                
                VStack {
                    HStack {
                        Button(player.rate == 0 ? "Play" : "Pause"){
                            player.rate = player.rate == 0 ? 1 : 0
                        }
                        
                        Button("Reset"){
                            timeBandit.wrappedValue = 0
                        }
                    }
                    
                    HStack {
                        Slider(value: $player.volume, in: 0...1)
                        Text("Volume")
                    }
                    
                    HStack {
                        Slider(value: $player.rate, in: 0...10)
                        Text("Speed")
                    }
                    
                    Slider(value: timeBandit, in: 0...(Double(item.duration.value) / 1000))
                        .onAppear{
                            Task{ @MainActor in
                                for await time in player.timeStream(atInterval: 0.01) {
                                    self.time = time
                                }
                            }
                        }
                }
                .padding()
                .animation(.smooth, value: player.rate)
            }
        }
        .animation(.bouncy, value: player.status)
    }
    
}


#Preview("AVKit Example"){
    AVKitExample(player: AVPlayerObservable(url: .eliSladeProfilePosesVideo))
}
