import SwiftUI

struct MainKeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }
    var isLiquidGlass: Bool { settings.useNativeIOSLayout || theme.useFrostedGlass }

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
            VStack(spacing: 0) {
                if !settings.useNativeIOSLayout {
                    ToolbarView(viewModel: viewModel)
                        .zIndex(1)
                        .padding(.bottom, 2)
                } else {
                    Spacer().frame(height: 8)
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
                            .padding(.bottom, 8)
                    } else {
                        SuggestionStripView(viewModel: viewModel)
                            .zIndex(100)
                            .padding(.bottom, settings.useNativeIOSLayout ? 10 : 4)
                    }

                    // Dedicated Number Row (if enabled)
                    if settings.showDedicatedNumberRow && viewModel.keyboardMode == .alphabetic {
                        let hasActiveKey = KeyModel.dedicatedNumberRow().contains { $0.id == viewModel.activePopupKeyId }
                        HStack(spacing: 6) {
                            ForEach(KeyModel.dedicatedNumberRow()) { key in
                                KeyButtonView(key: key, viewModel: viewModel)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 6.5)
                        .padding(.bottom, settings.useNativeIOSLayout ? 9 : 5)
                        .zIndex(hasActiveKey ? 200 : 10)
                    }

                    // Main Key Rows (Row 1, Row 2, Row 3) with exact iOS 26 Liquid Glass spacing (11pt vertical, 6pt horizontal)
                    let rows = activeRows
                    VStack(spacing: settings.useNativeIOSLayout ? 11 : 6) {
                        ForEach(0..<rows.count, id: \.self) { rowIndex in
                            let rowKeys = rows[rowIndex]
                            let hasActiveKey = rowKeys.contains { $0.id == viewModel.activePopupKeyId }

                            if rowIndex == 2 && viewModel.keyboardMode == .alphabetic && rowKeys.count >= 3 {
                                // Row 3 exact iOS geometry: 44pt Shift + 13.7pt gap + 7 letter keys (6pt spacing) + 13.7pt gap + 44pt Backspace
                                HStack(spacing: 0) {
                                    KeyButtonView(key: rowKeys.first!, viewModel: viewModel)
                                        .frame(width: 44.0)

                                    Spacer(minLength: 13.5)

                                    HStack(spacing: 6.0) {
                                        ForEach(Array(rowKeys.dropFirst().dropLast())) { key in
                                            KeyButtonView(key: key, viewModel: viewModel)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }

                                    Spacer(minLength: 13.5)

                                    KeyButtonView(key: rowKeys.last!, viewModel: viewModel)
                                        .frame(width: 44.0)
                                }
                                .padding(.horizontal, 6.5)
                                .zIndex(hasActiveKey ? 300 : Double(20 - rowIndex))
                            } else {
                                // Row 1 (6.5pt side inset) & Row 2 (25.8pt side inset so 9 keys match Row 1's exact 32.6pt key width!)
                                HStack(spacing: 6.0) {
                                    ForEach(rowKeys) { key in
                                        KeyButtonView(key: key, viewModel: viewModel)
                                            .frame(maxWidth: key.widthMultiplier > 1.0 ? 44.0 : .infinity)
                                    }
                                }
                                .padding(.horizontal, (rowIndex == 1 && viewModel.keyboardMode == .alphabetic) ? 25.8 : 6.5)
                                .zIndex(hasActiveKey ? 300 : Double(20 - rowIndex))
                            }
                        }

                        // Row 4: Bottom Control Row
                        if settings.useNativeIOSLayout {
                            // Exact iOS 26 Bottom Row (IMG_1457_8c6c10.png): 42.3pt 123 + 6pt gap + 42.3pt Emoji + 6pt gap + Spacebar + 6pt gap + 90.7pt Return
                            HStack(spacing: 6.0) {
                                // 123 / ABC Key (42.3pt wide, 43pt tall, same translucent Liquid Glass keycap!)
                                KeyButtonView(
                                    key: KeyModel(
                                        id: "ios_mode_toggle",
                                        primaryText: viewModel.keyboardMode == .alphabetic ? "123" : "ABC",
                                        type: .numberToggle
                                    ),
                                    viewModel: viewModel
                                )
                                .frame(width: 42.3)

                                // Emoji Key (42.3pt wide, 43pt tall; long-press opens Quick Settings / Themes!)
                                KeyButtonView(
                                    key: KeyModel(
                                        id: "ios_emoji_toggle",
                                        primaryText: "emoji",
                                        type: .emojiToggle
                                    ),
                                    viewModel: viewModel
                                )
                                .frame(width: 42.3)

                                // Spacebar with subtle bottom-right "A" and cursor slide
                                KeyButtonView(
                                    key: KeyModel(id: "ios_spacebar", primaryText: "space", type: .spacebar),
                                    viewModel: viewModel
                                )
                                .frame(maxWidth: .infinity)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 12)
                                        .onChanged { value in
                                            if settings.enableSpacebarCursorTrackpad {
                                                let offset = Int(value.translation.width / 14)
                                                if abs(offset) > 0 {
                                                    viewModel.onAdjustCursor?(offset > 0 ? 1 : -1)
                                                }
                                            }
                                        }
                                )

                                // Return Key (90.7pt wide, 43pt tall, same translucent Liquid Glass keycap!)
                                KeyButtonView(
                                    key: KeyModel(id: "ios_return", primaryText: "return", type: .returnKey),
                                    viewModel: viewModel
                                )
                                .frame(width: 90.7)
                            }
                            .padding(.horizontal, 6.5)
                            .zIndex(5)
                        } else {
                            // Standard Gboard Android Bottom Row (?123, Comma, Emoji, G English Spacebar, Period, Return)
                            HStack(spacing: 5) {
                                KeyButtonView(
                                    key: KeyModel(
                                        id: "gb_mode_toggle",
                                        primaryText: viewModel.keyboardMode == .alphabetic ? "?123" : "ABC",
                                        type: .numberToggle
                                    ),
                                    viewModel: viewModel
                                )
                                .frame(width: 46)

                                KeyButtonView(
                                    key: KeyModel(id: "bottom_comma", primaryText: ",", alternateVariants: [",", ";", ":", "'", "\""], type: .character(",")),
                                    viewModel: viewModel
                                )
                                .frame(width: 34)

                                KeyButtonView(
                                    key: KeyModel(id: "gb_emoji_toggle", primaryText: "emoji", type: .emojiToggle),
                                    viewModel: viewModel
                                )
                                .frame(width: 38)

                                KeyButtonView(
                                    key: KeyModel(id: "bottom_spacebar", primaryText: "space", type: .spacebar),
                                    viewModel: viewModel
                                )
                                .frame(maxWidth: .infinity)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 12)
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

                                KeyButtonView(
                                    key: KeyModel(id: "bottom_return", primaryText: "return", type: .returnKey),
                                    viewModel: viewModel
                                )
                                .frame(width: 58)
                            }
                            .padding(.horizontal, 6.5)
                            .zIndex(5)
                        }
                    }
                }
                Spacer(minLength: 3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isLiquidGlass ? Color.clear : Color(hex: theme.backgroundColorHex).ignoresSafeArea())
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
