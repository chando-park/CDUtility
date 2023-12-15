//
//  EmailService.swift
//  Phonics
//
//  Created by Littlefox iOS Developer on 12/12/23.
//  Copyright © 2023 com.littlefox. All rights reserved.
//

import MessageUI
import Combine
import SwiftUI

public struct EmailComposeView: UIViewControllerRepresentable {
    
    let to: String
    let subject: String
    let message: String
    
    var canUseAction: (() -> Void)? = nil
    
    public init(to: String, subject: String, message: String, canUseAction: (() -> Void)? = nil) {
        self.to = to
        self.subject = subject
        self.message = message
        self.canUseAction = canUseAction
    }
    
    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        public func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<EmailComposeView>) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = context.coordinator
        viewController.setToRecipients([to])
        viewController.setSubject(subject)
        viewController.setMessageBody(message, isHTML: false)
        if MFMailComposeViewController.canSendMail(){
            canUseAction?()
        }
        return viewController
    }

    public func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<EmailComposeView>) {
    }
}