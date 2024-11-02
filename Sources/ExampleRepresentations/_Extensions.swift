import Foundation

extension URL {
    
    static let googleWebSite = URL(string: "https://google.com")!

    static let appleWebSite = URL(string: "https://apple.com")!
    static let appleEnvironment2024PDF = appleWebSite.appendingPathComponent("environment/pdf/Apple_Environmental_Progress_Report_2024.pdf")
    
    static let eliSladeWebSite = URL(string: "https://elislade.com")!
    static let eliSladeProfilePosesVideo = eliSladeWebSite.appendingPathComponent("assets/images/ProfilePoses.mp4")
    static let eliSladeHeroSampleVideo = eliSladeWebSite.appendingPathComponent("assets/HeroSample.mp4")
    
}
