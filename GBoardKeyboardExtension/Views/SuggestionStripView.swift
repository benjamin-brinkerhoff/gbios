import SwiftUI

struct SuggestionStripView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject var suggestionState: SuggestionState
    @ObservedObject private var settings = KeyboardSettings.shared

    init(viewModel: KeyboardViewModel) {
        self.viewModel = viewModel
        self.suggestionState = viewModel.suggestionState
    }

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        ZStack {
            if suggestionState.activePopupKeyId != nil && !suggestionState.activePopupVariants.isEmpty {
                HStack(spacing: 6) {
                    Text("Release to insert:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: theme.textSecondaryHex))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(suggestionState.activePopupVariants.enumerated()), id: \.offset) { idx, variant in
                                Button {
                                    viewModel.selectPopupVariant(variant)
                                } label: {
                                    Text(variant)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(idx == suggestionState.selectedVariantIndex ? .white : Color(hex: theme.textPrimaryHex))
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                                .fill(idx == suggestionState.selectedVariantIndex ? Color(hex: theme.accentColorHex) : Color(hex: theme.keyColorHex))
                                        )
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 8)
            } else {
                HStack(spacing: 0) {
                    if let calcResult = suggestionState.calculatedMathResult {
                        Button {
                            viewModel.triggerTouchDownFeedback()
                            viewModel.insertText(calcResult)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "equal.circle.fill")
                                    .foregroundColor(.green)
                                Text(calcResult)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(hex: theme.keyColorHex))
                            .cornerRadius(7)
                        }
                        .padding(.horizontal, 4)
                    }

                    ForEach(Array(suggestionState.suggestions.enumerated()), id: \.offset) { idx, word in
                        Button {
                            viewModel.applySuggestion(word)
                        } label: {
                            Text(word)
                                .font(.system(size: 16.5, weight: .regular))
                                .foregroundColor(Color(hex: theme.textPrimaryHex).opacity(0.92))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }

                        if idx < suggestionState.suggestions.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(theme.isDark ? 0.16 : 0.25))
                                .frame(width: 0.6, height: 20)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .frame(height: 38)
    }
}
