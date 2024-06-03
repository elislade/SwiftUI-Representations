import SwiftUI

#if canImport(UIKit)
import MessageUI

public struct MessageComposeViewCtrlRepresentation {
    
    let subject: String?
    let body: String
    let recipients: [String]
    let attachments: [Attachment]
    let didFinishWithResult: (MessageComposeResult) -> Void
    
    static var canSendText: Bool {
        MFMessageComposeViewController.canSendText()
    }
    
    static var canSendSubject: Bool {
        MFMessageComposeViewController.canSendSubject()
    }
    
    static var canSendAttachments: Bool {
        MFMessageComposeViewController.canSendAttachments()
    }
    
    public init(
        subject: String? = nil,
        body: String = "",
        recipients: [String] = [],
        attachments: [Attachment] = [],
        didFinishWithResult: @escaping (MessageComposeResult) -> Void = { _ in }
    ){
        self.subject = subject
        self.body = body
        self.recipients = recipients
        self.attachments = attachments
        self.didFinishWithResult = didFinishWithResult
    }
    
    private func sync(ctrl: MFMessageComposeViewController){
        ctrl.recipients = recipients
        ctrl.subject = subject
        ctrl.body = body
    }
    
    public class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let didFinishWithResult: (MessageComposeResult) -> Void
        
        public init(_ didFinishWithResult: @escaping (MessageComposeResult) -> Void) {
            self.didFinishWithResult = didFinishWithResult
        }
        
        public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: {
                self.didFinishWithResult(result)
            })
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(didFinishWithResult)
    }
    
}

extension MessageComposeViewCtrlRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let ctrl = MFMessageComposeViewController()
        ctrl.messageComposeDelegate = context.coordinator
        sync(ctrl: ctrl)
        
        for attachment in attachments {
            switch attachment {
            case let .url(url, alternateFilename):
                ctrl.addAttachmentURL(url, withAlternateFilename: alternateFilename)
            case let .data(data, mimeType, filename):
                ctrl.addAttachmentData(data, typeIdentifier: mimeType, filename: filename)
            }
        }

        return ctrl
    }

    public func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        sync(ctrl: uiViewController)
    }
    
}

#endif
