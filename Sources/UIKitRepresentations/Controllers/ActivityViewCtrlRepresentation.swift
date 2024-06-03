import SwiftUI

#if canImport(UIKit)
import UIKit

public struct ActivityViewCtrlRepresentation {

    let activityItems: [Any]
    let appActivities: [UIActivity]?
    let excludedActivityTypes: [UIActivity.ActivityType]?
    let allowsProminentActivity: Bool
    
    public init(
        activityItems: [Any] = [],
        appActivities: [UIActivity]?,
        excludedActivityTypes: [UIActivity.ActivityType]? = nil,
        allowsProminentActivity: Bool = true
    ) {
        self.activityItems = activityItems
        self.appActivities = appActivities
        self.excludedActivityTypes = excludedActivityTypes
        self.allowsProminentActivity = allowsProminentActivity
    }
    
    func sync(ctrl: UIActivityViewController) {
        ctrl.excludedActivityTypes = excludedActivityTypes
        if #available(iOS 15.4, *) {
            ctrl.allowsProminentActivity = allowsProminentActivity
        }
    }
    
}


extension ActivityViewCtrlRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let ctrl = UIActivityViewController(activityItems: activityItems, applicationActivities: appActivities)
        sync(ctrl: ctrl)
        return ctrl
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        sync(ctrl: uiViewController)
    }
    
}


extension Collection where Element == UIActivity.ActivityType {
    
    static var social: Set<Element> {
        [
            .postToFacebook, .postToFlickr, .postToTencentWeibo,
            .postToTwitter, .postToVimeo, .postToWeibo
        ]
    }
    
    static var firstPartyApps: Set<Element> {
        [
            .addToReadingList, .openInIBooks, .markupAsPDF
        ]
    }
    
}

#endif
