import SwiftUI

struct MainKeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    private var activeRows: [[KeyModel]] {
        switch viewModel.keyboardMode {
        case .alphabetic:
            return KeyModel.defaultQwertyRows(showSecondary: settings.showSecondarySymbols)
        case .numbers:
            return KeyModel.numberAndPunctuationRows()
        case .symbols:
            return KeyModel.secondarySymbolRows()
        }
    }

    var body: some View {
        OneHandedContainerView {
            VStack(spacing: settings.useNativeIOSLayout ? 5 : 3) {
                // If in Native iOS Mode, hide Gboard Toolbar and show clean 3-word predictive strip unless a drawer is active
                if !settings.useNativeIOSLayout {
                    ToolbarView(viewModel: viewModel)
                        .zIndex(1)
                }

                switch viewModel.activeDrawer {
                case .clipboard:
                    ClipboardView(viewModel: viewModel)
                case .voiceDictation:
                    VoiceDictationPanelView(viewModel: viewModel)
                case .aiWritingTools:
                    AIWritingToolsView(viewModel: viewModel)
                case .textEditingPad:
                    TextEditingPadView(viewModel: viewModel)
                case .cameraOCR:
                    CameraOCRView(viewModel: viewModel)
                case .emojiPalette:
                    EmojiPaletteView(viewModel: viewModel)
                case .quickSettings:
                    QuickSettingsDrawerView(viewModel: viewModel)
                case .translate, .none:
                    if viewModel.activeDrawer == .translate {
                        TranslateView(viewModel: viewModel)
                            .zIndex(100)
                    } else {
                        // Native iOS 3-Column Prediction Strip (or Gboard strip)
                        SuggestionStripView(viewModel: viewModel)
                            .zIndex(100)
                    }

                    // Dedicated Number Row (if enabled on alphabetic mode and not in minimal iOS mode)
                    if settings.showDedicatedNumberRow && viewModel.keyboardMode == .alphabetic && !settings.useNativeIOSLayout {
                        let hasActiveKey = KeyModel.dedicatedNumberRow().contains { $0.id == viewModel.activePopupKeyId }
                        HStack(spacing: 4) {
                            ForEach(KeyModel.dedicatedNumberRow()) { key in
                                KeyButtonView(key: key, viewModel: viewModel)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 2)
                        .zIndex(hasActiveKey ? 200 : 10)
                    }

                    // Main Key Rows (QWERTY, Numbers, or Symbols)
                    let rows = activeRows
                    ForEach(0..<rows.count, id: \.self) { rowIndex in
                        let rowKeys = rows[rowIndex]
                        let hasActiveKey = rowKeys.contains { $0.id == viewModel.activePopupKeyId }

                        HStack(spacing: settings.useNativeIOSLayout ? 6 : 4) {
                            ForEach(rowKeys) { key in
                                KeyButtonView(key: key, viewModel: viewModel)
                                    .frame(maxWidth: key.widthMultiplier > 1.0 ? 46 : .infinity)
                            }
                        }
                        .padding(.horizontal, rowIndex == 1 && viewModel.keyboardMode == .alphabetic ? (settings.useNativeIOSLayout ? 16 : 14) : 3)
                        .zIndex(hasActiveKey ? 300 : Double(20 - rowIndex))
                    }

                    // Bottom Control Row
                    if settings.useNativeIOSLayout {
                        // Native Apple iOS Bottom Row (ec2fbc08.jpeg): [ 123 ] [ 😃 ] [ spacebar ] [ ↩ ]
                        HStack(spacing: 6) {
                            // 123 / ABC Mode Toggle
                            Button {
                                viewModel.triggerHaptic()
                                viewModel.dismissPopup()
                                if viewModel.keyboardMode == .alphabetic {
                                    viewModel.keyboardMode = .numbers
                                } else {
                                    viewModel.keyboardMode = .alphabetic
                                }
                            } label: {
                                Text(viewModel.keyboardMode == .alphabetic ? "123" : "ABC")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                                    .frame(width: 44, height: 42)
                                    .background(Color(hex: theme.functionalKeyColorHex))
                                    .cornerRadius(5)
                                    .shadow(color: Color.black.opacity(0.18), radius: 0.8, x: 0, y: 1)
                            }

                            // Emoji Key
                            Button {
                                viewModel.triggerHaptic()
                                viewModel.dismissPopup()
                                viewModel.activeDrawer = (viewModel.activeDrawer == .emojiPalette) ? .none : .emojiPalette
                            } label: {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                                    .frame(width: 44, height: 42)
                                    .background(Color(hex: theme.functionalKeyColorHex))
                                    .cornerRadius(5)
                                    .shadow(color: Color.black.opacity(0.18), radius: 0.8, x: 0, y: 1)
                            }

                            // Clean Apple-style Spacebar with cursor slide
                            KeyButtonView(
                                key: KeyModel(id: "ios_spacebar", primaryText: "space", type: .spacebar),
                                viewModel: viewModel
                            )
                            .frame(maxWidth: .infinity)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 10)
                                    .onChanged { value in
                                        if settings.enableSpacebarCursorTrackpad {
                                            let offset = Int(value.translation.width / 14)
                                            if abs(offset) > 0 {
                                                viewModel.onAdjustCursor?(offset > 0 ? 1 : -1)
                                            }
                                        }
                                    }
                            )

                            // Native iOS Return Key with angled curved arrow
                            Button {
                                viewModel.handleKeyPress(KeyModel(id: "ios_return", primaryText: "return", type: .returnKey))
                            } label: {
                                Image(systemName: "return")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                                    .frame(width: 76, height: 42)
                                    .background(Color(hex: theme.functionalKeyColorHex))
                                    .cornerRadius(5)
                                    .shadow(color: Color.black.opacity(0.18), radius: 0.8, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal, 3)
                        .zIndex(5)
                    } else {
                        // Standard Gboard Android Bottom Row (?123, Comma, Emoji, G English Spacebar, Period, Return)
                        HStack(spacing: 4) {
                            Button {
                                viewModel.triggerHaptic()
                                viewModel.dismissPopup()
                                if viewModel.keyboardMode == .alphabetic {
                                    viewModel.keyboardMode = .numbers
                                } else {
                                    viewModel.keyboardMode = .alphabetic
                                }
                            } label: {
                                Text(viewModel.keyboardMode == .alphabetic ? "?123" : "ABC")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                                    .frame(width: 48, height: 42)
                                    .background(Color(hex: theme.functionalKeyColorHex))
                                    .cornerRadius(settings.keycapStyle.cornerRadius)
                            }

                            KeyButtonView(
                                key: KeyModel(id: "bottom_comma", primaryText: ",", alternateVariants: [",", ";", ":", "'", "\""], type: .character(",")),
                                viewModel: viewModel
                            )
                            .frame(width: 34)

                            Button {
                                viewModel.triggerHaptic()
                                viewModel.dismissPopup()
                                viewModel.activeDrawer = (viewModel.activeDrawer == .emojiPalette) ? .none : .emojiPalette
                            } label: {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                                    .frame(width: 36, height: 42)
                                    .background(Color(hex: theme.functionalKeyColorHex))
                                    .cornerRadius(settings.keycapStyle.cornerRadius)
                            }

                            KeyButtonView(
                                key: KeyModel(id: "bottom_spacebar", primaryText: "space", type: .spacebar),
                                viewModel: viewModel
                            )
                            .frame(maxWidth: .infinity)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 10)
                                    .onChanged { value in
                                        if settings.enableSpacebarCursorTrackpad {
                                            let offset = Int(value.translation.width / 14)
                                            if abs(offset) > 0 {
                                                viewModel.onAdjustCursor?(offset > 0 ? 1 : -1)
                                            }
                                        }
                                    }
                            )

                            KeyButtonView(
                                key: KeyModel(id: "bottom_period", primaryText: ".", alternateVariants: [".", "?", "!", ",", "@", "/", ":", "-"], type: .character(".")),
                                viewModel: viewModel
                            )
                            .frame(width: 34)

                            Button {
                                viewModel.handleKeyPress(KeyModel(id: "bottom_return", primaryText: "return", type: .returnKey))
                            } label: {
                                Image(systemName: "return")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 54, height: 42)
                                    .background(Color(hex: theme.accentColorHex))
                                    .cornerRadius(settings.keycapStyle.cornerRadius)
                            }
                        }
                        .padding(.horizontal, 2)
                        .zIndex(5)
                    }
                }
            }
            .padding(.top, 2)
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: theme.backgroundColorHex).ignoresSafeArea())
        }
    }
}

struct VoiceDictationPanelView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var voiceVM = VoiceTypingViewModel()
    @ObservedObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Gemini Rambler Voice Dictation")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                Spacer()
                Button("Done") {
                    voiceVM.stopRecording()
                    viewModel.activeDrawer = .none
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: theme.accentColorHex))
            }
            .padding(.horizontal, 10)

            Text(voiceVM.transcription.isEmpty ? voiceVM.statusMessage : voiceVM.transcription)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: theme.textPrimaryHex))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .frame(height: 50)

            Button {
                voiceVM.toggleRecording()
            } label: {
                Image(systemName: voiceVM.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 54))
                    .foregroundColor(voiceVM.isRecording ? .red : Color(hex: theme.accentColorHex))
            }
        }
        .frame(height: 180)
        .background(Color(hex: theme.functionalKeyColorHex))
        .onAppear {
            voiceVM.onFinalText = { text in
                viewModel.insertText(text)
            }
        }
    }
}
