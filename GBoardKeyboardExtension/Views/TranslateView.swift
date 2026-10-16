import SwiftUI

struct TranslateView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared
    @StateObject private var translationService = TranslationService.shared

    var theme: KeyboardTheme { settings.currentTheme }
    var sourceLang: TranslationLanguage { TranslationLanguage.language(for: settings.translateSourceLang) }
    var targetLang: TranslationLanguage { TranslationLanguage.language(for: settings.translateTargetLang) }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Menu {
                    ForEach(TranslationLanguage.sourceLanguages) { lang in
                        Button("\(lang.flag) \(lang.name)") {
                            settings.translateSourceLang = lang.code
                            viewModel.retranslateActiveBuffer()
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(sourceLang.flag)
                        Text(sourceLang.name)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: theme.keyColorHex))
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                    .cornerRadius(6)
                }

                Button {
                    viewModel.triggerHaptic()
                    settings.swapTranslationLanguages()
                    viewModel.retranslateActiveBuffer()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: theme.accentColorHex))
                        .frame(width: 28, height: 26)
                        .background(Color(hex: theme.keyColorHex))
                        .cornerRadius(6)
                }

                Menu {
                    ForEach(TranslationLanguage.supportedLanguages) { lang in
                        Button("\(lang.flag) \(lang.name)") {
                            settings.translateTargetLang = lang.code
                            viewModel.retranslateActiveBuffer()
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(targetLang.flag)
                        Text(targetLang.name)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: theme.keyColorHex))
                    .foregroundColor(Color(hex: theme.accentColorHex))
                    .cornerRadius(6)
                }

                Spacer()

                if !viewModel.contextBefore.isEmpty && viewModel.translateInputBuffer.isEmpty {
                    Button {
                        viewModel.triggerHaptic()
                        viewModel.translateCurrentDocumentContext()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("Field")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .background(Color(hex: theme.accentColorHex).opacity(0.18))
                        .foregroundColor(Color(hex: theme.accentColorHex))
                        .cornerRadius(6)
                    }
                }

                Button {
                    viewModel.commitOrCloseTranslate()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: theme.textSecondaryHex))
                }
            }
            .padding(.horizontal, 8)

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    if viewModel.translateInputBuffer.isEmpty {
                        Text("Type on keyboard to translate into \(targetLang.name)...")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: theme.textSecondaryHex))
                            .lineLimit(1)
                    } else {
                        Text(viewModel.translateInputBuffer)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: theme.textSecondaryHex))
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            if viewModel.isTranslating {
                                ProgressView()
                                    .scaleEffect(0.6)
                            }
                            Text(viewModel.translatedPreviewText.isEmpty ? "Translating..." : viewModel.translatedPreviewText)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: theme.textPrimaryHex))
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                if !viewModel.translateInputBuffer.isEmpty {
                    Button {
                        viewModel.clearTranslateBuffer()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: theme.textSecondaryHex))
                            .padding(6)
                    }

                    Button {
                        viewModel.insertTranslatedBuffer()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Insert")
                                .font(.system(size: 12, weight: .bold))
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 11))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: theme.accentColorHex))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: theme.keyColorHex))
            .cornerRadius(8)
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 4)
        .background(Color(hex: theme.functionalKeyColorHex))
    }
}
