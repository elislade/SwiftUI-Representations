import SwiftUI

extension URL {
    
    static let googleWebSite = URL(string: "https://www.google.com/")!

    static let appleWebSite = URL(string: "https://apple.com")!
    static let appleEnvironment2024PDF = appleWebSite.appendingPathComponent("environment/pdf/Apple_Environmental_Progress_Report_2024.pdf")
    
    static let eliSladeWebSite = URL(string: "https://elislade.com")!
    static let eliSladeProfilePosesVideo = eliSladeWebSite.appendingPathComponent("assets/images/ProfilePoses.mp4")
    static let eliSladeHeroSampleVideo = eliSladeWebSite.appendingPathComponent("assets/HeroSample.mp4")
    
}


extension View {
    
    #if os(macOS)
    
    func previewSize() -> some View {
        frame(width: 320, height: 560)
    }
    
    #else
    
    func previewSize() -> Self {
        self
    }
    
    #endif
    
}
