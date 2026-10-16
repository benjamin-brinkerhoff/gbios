import SwiftUI

struct SuggestionStripView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        ZStack {
            if viewModel.activePopupKeyId != nil && !viewModel.activePopupVariants.isEmpty {
                // Clickable Long-Press Character Bar
                HStack(spacing: 6) {
                    Text("Select:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: theme.textSecondaryHex))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(viewModel.activePopupVariants.enumerated()), id: \.offset) { idx, variant in
                                Button {
                                    viewModel.selectPopupVariant(variant)
                                } label: {
                                    Text(variant)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(idx == viewModel.selectedVariantIndex ? .white : Color(hex: theme.textPrimaryHex))
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                                .fill(idx == viewModel.selectedVariantIndex ? Color(hex: theme.accentColorHex) : Color(hex: theme.keyColorHex))
                                        )
                                }
                            }
                        }
                    }

                    Spacer()

                    Button {
                        viewModel.dismissPopup()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: theme.textSecondaryHex))
                    }
                }
                .padding(.horizontal, 8)
            } else {
                // Native iOS 26 3-Column Prediction Strip (exact match to IMG_1457_8c6c10.png)
                HStack(spacing: 0) {
                    if let calcResult = viewModel.calculatedMathResult {
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

                    ForEach(Array(viewModel.suggestions.enumerated()), id: \.offset) { idx, word in
                        Button {
                            viewModel.applySuggestion(word)
                        } label: {
                            Text(word)
                                .font(.system(size: 16.5, weight: .regular))
                                .foregroundColor(Color(hex: theme.textPrimaryHex).opacity(0.92))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }

                        if idx < viewModel.suggestions.count - 1 {
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
