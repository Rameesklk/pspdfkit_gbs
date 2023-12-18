//
//  Copyright © 2019-2022 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Instant
import PSPDFKit

/**
 Downloads and shows a document managed by Instant, and shows a
 button to share the document URL so you can see Instant syncing.
 */

public class InstantDocumentViewController: InstantViewController {

    private var buttonStackView: UIStackView!
    private var greyButton: UIButton!
    private var redButton: UIButton!

    private let documentInfo: InstantDocumentInfo

    @objc public let client: InstantClient
    @objc public let documentDescriptor: InstantDocumentDescriptor

    @objc public init(documentInfo: InstantDocumentInfo, configurations: PDFConfiguration) throws {
        self.documentInfo = documentInfo

        client = try InstantClient(serverURL: documentInfo.serverURL)
        documentDescriptor = try client.documentDescriptor(forJWT: documentInfo.jwt)

        super.init(document: documentDescriptor.editableDocument, configuration: configurations)

        // Set up buttons
        greyButton = createButton(title: "Public", backgroundColor: .red)
        redButton = createButton(title: "Private", backgroundColor: .gray)

        // Add buttons to stack view
        buttonStackView = UIStackView(arrangedSubviews: [greyButton, redButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 5
        buttonStackView.alignment = .leading

        // Add the stack view to the view
        view.addSubview(buttonStackView)

        // Set up stack view constraints for centering
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
       NSLayoutConstraint.activate([
           buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
           buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
       ])

        // Add tap actions to buttons
        greyButton.addTarget(self, action: #selector(greyButtonTapped), for: .touchUpInside)
        redButton.addTarget(self, action: #selector(redButtonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) is not supported!.")
    }

   @objc private func greyButtonTapped() {
       DispatchQueue.main.async {
           self.toggleButtonColors(self.greyButton)
           self.switchJWTAndLoadDocument(jwt: self.documentInfo.tokens[0])
       }
   }

   @objc private func redButtonTapped() {
       DispatchQueue.main.async {
           self.toggleButtonColors(self.redButton)
           self.switchJWTAndLoadDocument(jwt: self.documentInfo.tokens[1])
       }
   }

    private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }

    private func toggleButtonColors(_ tappedButton: UIButton) {
        greyButton.backgroundColor = .gray
        redButton.backgroundColor = .gray
        greyButton.setTitleColor(.black, for: .normal)
        redButton.setTitleColor(.black, for: .normal)

        // Toggle the tapped button color
        tappedButton.backgroundColor = .red
        tappedButton.setTitleColor(.white, for: .normal)
    }

    private func switchJWTAndLoadDocument(jwt: String) {
        do {
            try documentDescriptor.reauthenticate(withJWT: jwt)
//             try documentDescriptor.download(usingJWT: jwt)
        } catch {
            print("Error switching JWT: \(error)")
        }
        DispatchQueue.main.async {
            self.loadDocument()
        }
    }

    private func loadDocument() {
        guard let documentDescriptor = documentDescriptor as? InstantDocumentDescriptor else {
            return
        }
        let pdfDocument = documentDescriptor.editableDocument
        DispatchQueue.main.async {
            self.document = pdfDocument
        }
    }

    private let notificationNames: [Notification.Name] = [.PSPDFInstantDidFailDownload, .PSPDFInstantDidFailSyncing, .PSPDFInstantDidFailAuthentication, .PSPDFInstantDidFailReauthentication]

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        for name in notificationNames {
            NotificationCenter.default.removeObserver(self, name: name, object: documentDescriptor)
        }
    }

}
