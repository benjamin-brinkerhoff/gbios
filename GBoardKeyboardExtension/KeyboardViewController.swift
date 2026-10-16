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
        let settings = KeyboardSettings.shared
        let theme = settings.currentTheme
        if settings.useNativeIOSLayout || theme.useFrostedGlass {
            // Use completely clear background so iOS 26 system Liquid Glass backdrop shines through seamlessly with zero top/bottom chin seam
            view.backgroundColor = .clear
            inputView?.backgroundColor = .clear
            view.superview?.backgroundColor = .clear
            hostingController?.view.backgroundColor = .clear
        } else {
            let bgColor = UIColor(Color(hex: theme.backgroundColorHex))
            view.backgroundColor = bgColor
            inputView?.backgroundColor = bgColor
            view.superview?.backgroundColor = bgColor
            hostingController?.view.backgroundColor = bgColor
        }
    }

    private func updateKeyboardHeight() {
        let settings = KeyboardSettings.shared
        if settings.useNativeIOSLayout {
            heightConstraint?.constant = 268
        } else {
            let hasNumberRow = settings.showDedicatedNumberRow
            heightConstraint?.constant = hasNumberRow ? 286 : 254
        }
    }

    private func setupCallbacks() {
        viewModel.onPlayClick = { [weak self] in
            self?.playClick()
        }
        viewModel.onInsertText = { [weak self] text in
            guard let self = self else { return }
            self.textDocumentProxy.insertText(text)
            self.refreshDocumentContextAsync()
        }
        viewModel.onDeleteBackward = { [weak self] in
            guard let self = self else { return }
            self.textDocumentProxy.deleteBackward()
            self.refreshDocumentContextAsync()
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
            self.refreshDocumentContextAsync()
        }
    }

    private func refreshDocumentContextAsync() {
        let before = textDocumentProxy.documentContextBeforeInput
        let after = textDocumentProxy.documentContextAfterInput
        viewModel.updateContext(before: before, after: after)
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

        let initialHeight: CGFloat = KeyboardSettings.shared.useNativeIOSLayout ? 268 : (KeyboardSettings.shared.showDedicatedNumberRow ? 286 : 254)
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
        applyThemeBackground()
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
