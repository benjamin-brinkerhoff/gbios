import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    private var viewModel = KeyboardViewModel()
    private var hostingController: UIHostingController<MainKeyboardView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallbacks()
        setupSwiftUIHierarchy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.needsInputModeSwitchKey = needsInputModeSwitchKey
        viewModel.refreshClipboard()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        viewModel.updateContext(
            before: textDocumentProxy.documentContextBeforeInput,
            after: textDocumentProxy.documentContextAfterInput
        )
    }

    private func setupCallbacks() {
        viewModel.onInsertText = { [weak self] text in
            self?.textDocumentProxy.insertText(text)
            self?.playClick()
        }
        viewModel.onDeleteBackward = { [weak self] in
            self?.textDocumentProxy.deleteBackward()
            self?.playClick()
        }
        viewModel.onNextKeyboard = { [weak self] in
            self?.advanceToNextInputMode()
        }
        viewModel.onDismissKeyboard = { [weak self] in
            self?.dismissKeyboard()
        }
        viewModel.onAdjustCursor = { [weak self] offset in
            self?.textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
        }
        viewModel.onReplaceRange = { [weak self] length, newText in
            guard let self = self else { return }
            for _ in 0..<length {
                self.textDocumentProxy.deleteBackward()
            }
            self.textDocumentProxy.insertText(newText)
        }
    }

    private func setupSwiftUIHierarchy() {
        let rootView = MainKeyboardView(viewModel: viewModel)
        let host = UIHostingController(rootView: rootView)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        view.backgroundColor = .clear

        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)

        let heightConstraint = host.view.heightAnchor.constraint(equalToConstant: 295)
        heightConstraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heightConstraint
        ])

        self.hostingController = host
    }

    private func playClick() {
        if KeyboardSettings.shared.enableKeyClickSound {
            UIDevice.current.playInputClick()
        }
    }
}

extension KeyboardViewController: UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { true }
}
