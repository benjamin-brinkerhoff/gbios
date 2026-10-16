import UIKit
import SwiftUI
import Combine

class KeyboardViewController: UIInputViewController {
    private var viewModel = KeyboardViewModel()
    private var hostingController: UIHostingController<MainKeyboardView>?
    private var heightConstraint: NSLayoutConstraint?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        KeyboardSettings.shared.reloadFromSharedStorage()
        setupCallbacks()
        setupSwiftUIHierarchy()
        observeThemeAndHeightChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardSettings.shared.reloadFromSharedStorage()
        viewModel.needsInputModeSwitchKey = needsInputModeSwitchKey
        viewModel.refreshClipboard()
        applyThemeBackground()
        updateKeyboardHeight()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        KeyboardSettings.shared.reloadFromSharedStorage()
        applyThemeBackground()
        updateKeyboardHeight()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyThemeBackground()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        viewModel.updateContext(
            before: textDocumentProxy.documentContextBeforeInput,
            after: textDocumentProxy.documentContextAfterInput
        )
    }

    private func observeThemeAndHeightChanges() {
        KeyboardSettings.shared.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.applyThemeBackground()
                    self?.updateKeyboardHeight()
                }
            }
            .store(in: &cancellables)
    }

    private func applyThemeBackground() {
        let theme = KeyboardSettings.shared.currentTheme
        let bgColor = UIColor(Color(hex: theme.backgroundColorHex))
        view.backgroundColor = bgColor
        inputView?.backgroundColor = bgColor
        view.superview?.backgroundColor = bgColor
        hostingController?.view.backgroundColor = bgColor
    }

    private func updateKeyboardHeight() {
        let hasNumberRow = KeyboardSettings.shared.showDedicatedNumberRow
        let targetHeight: CGFloat = hasNumberRow ? 286 : 246
        heightConstraint?.constant = targetHeight
    }

    private func setupCallbacks() {
        viewModel.onInsertText = { [weak self] text in
            self?.textDocumentProxy.insertText(text)
            self?.playClick()
            self?.refreshDocumentContext()
        }
        viewModel.onDeleteBackward = { [weak self] in
            self?.textDocumentProxy.deleteBackward()
            self?.playClick()
            self?.refreshDocumentContext()
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
            if length > 0 {
                for _ in 0..<length {
                    self.textDocumentProxy.deleteBackward()
                }
            }
            self.textDocumentProxy.insertText(newText)
            self.refreshDocumentContext()
        }
    }

    private func refreshDocumentContext() {
        viewModel.updateContext(
            before: textDocumentProxy.documentContextBeforeInput,
            after: textDocumentProxy.documentContextAfterInput
        )
    }

    private func setupSwiftUIHierarchy() {
        let rootView = MainKeyboardView(viewModel: viewModel)
        let host = UIHostingController(rootView: rootView)
        host.view.translatesAutoresizingMaskIntoConstraints = false

        let theme = KeyboardSettings.shared.currentTheme
        let bgColor = UIColor(Color(hex: theme.backgroundColorHex))
        host.view.backgroundColor = bgColor
        view.backgroundColor = bgColor

        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)

        let initialHeight: CGFloat = KeyboardSettings.shared.showDedicatedNumberRow ? 286 : 246
        let hc = host.view.heightAnchor.constraint(equalToConstant: initialHeight)
        hc.priority = UILayoutPriority(999)
        self.heightConstraint = hc

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hc
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
