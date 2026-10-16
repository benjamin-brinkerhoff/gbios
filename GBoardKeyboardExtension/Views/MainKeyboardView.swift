import SwiftUI

struct MainKeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        OneHandedContainerView {
            VStack(spacing: 4) {
                // Gboard Top Toolbar
                ToolbarView(viewModel: viewModel)

                // Active Drawer Panels
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
                case .none:
                    // Suggestion Strip
                    SuggestionStripView(viewModel: viewModel)

                    // Dedicated Number Row (if enabled)
                    if settings.showDedicatedNumberRow {
                        HStack(spacing: 5) {
                            ForEach(KeyModel.dedicatedNumberRow()) { key in
                                KeyButtonView(key: key, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    // QWERTY Rows
                    let rows = KeyModel.defaultQwertyRows(showSecondary: settings.showSecondarySymbols)
                    ForEach(0..<rows.count, id: \.self) { rowIndex in
                        HStack(spacing: 5) {
                            ForEach(rows[rowIndex]) { key in
                                KeyButtonView(key: key, viewModel: viewModel)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    // Bottom Control Row
                    HStack(spacing: 5) {
                        KeyButtonView(key: KeyModel(primaryText: "123", type: .numberToggle), viewModel: viewModel)
                            .frame(width: 44)

                        KeyButtonView(key: KeyModel(primaryText: "emoji", type: .emojiToggle), viewModel: viewModel)
                            .frame(width: 40)

                        if viewModel.needsInputModeSwitchKey {
                            KeyButtonView(key: KeyModel(primaryText: "globe", type: .globe), viewModel: viewModel)
                                .frame(width: 40)
                        }

                        // Spacebar with G-Logo and Cursor Dragging
                        KeyButtonView(key: KeyModel(primaryText: "space", type: .spacebar), viewModel: viewModel)
                            .frame(maxWidth: .infinity)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if settings.enableSpacebarCursorTrackpad {
                                            let offset = Int(value.translation.width / 12)
                                            if abs(offset) > 0 {
                                                viewModel.onAdjustCursor?(offset > 0 ? 1 : -1)
                                            }
                                        }
                                    }
                            )

                        KeyButtonView(key: KeyModel(primaryText: "return", type: .returnKey), viewModel: viewModel)
                            .frame(width: 76)
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.bottom, 6)
            .background(
                Group {
                    if theme.useFrostedGlass {
                        Color(hex: theme.backgroundColorHex)
                            .background(.ultraThinMaterial)
                    } else {
                        Color(hex: theme.backgroundColorHex)
                    }
                }
            )
        }
    }
}

struct VoiceDictationPanelView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var voiceVM = VoiceTypingViewModel()
    @StateObject private var settings = KeyboardSettings.shared

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
