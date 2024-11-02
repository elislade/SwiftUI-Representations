import SwiftUI

#if canImport(UIKit)
import MessageUI

public struct MFMailComposeViewControllerRepresentation {
    
    let subject: String
    let body: BodyContent
    let toRecipients: [String]
    let ccRecipients: [String]
    let bccRecipients: [String]
    let attachments: [Attachment]
    let preferredSendingEmailAddress: String?
    
    public enum BodyContent {
        case text(String)
        case html(String)
    }
    
    public static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    public init(
        subject: String,
        body: BodyContent = .text(""),
        toRecipients: [String] = [],
        ccRecipients: [String] = [],
        bccRecipients: [String] = [],
        attachments: [Attachment] = [],
        preferredSendingEmailAddress: String? = nil
    ) {
        self.subject = subject
        self.body = body
        self.toRecipients = toRecipients
        self.ccRecipients = toRecipients
        self.bccRecipients = bccRecipients
        self.attachments = attachments
        self.preferredSendingEmailAddress = preferredSendingEmailAddress
    }
    
    private func sync(ctrl: MFMailComposeViewController) {
        ctrl.setSubject(subject)
        ctrl.setToRecipients(toRecipients)
        ctrl.setCcRecipients(ccRecipients)
        ctrl.setBccRecipients(bccRecipients)
        
        switch body {
        case .text(let string):
            ctrl.setMessageBody(string, isHTML: false)
        case .html(let string):
            ctrl.setMessageBody(string, isHTML: true)
        }
        
        if let preferredSendingEmailAddress {
            ctrl.setPreferredSendingEmailAddress(preferredSendingEmailAddress)
        }
    }
    
    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
}

extension  MFMailComposeViewControllerRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let ctrl = MFMailComposeViewController()
        ctrl.mailComposeDelegate = context.coordinator
        sync(ctrl: ctrl)
        
        for attachment in attachments {
            if case let .data(data, mimeType, filename) = attachment{
                ctrl.addAttachmentData(
                    data,
                    mimeType: mimeType,
                    fileName: filename
                )
            }
        }
        
        return ctrl
    }

    public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        sync(ctrl: uiViewController)
    }
    
}


#Preview {
    if MFMailComposeViewControllerRepresentation.canSendMail {
        MFMailComposeViewControllerRepresentation(subject: "Hello World")
    } else {
        Text("This devices account does not support email composing.")
            .multilineTextAlignment(.center)
    }
}

#endif
