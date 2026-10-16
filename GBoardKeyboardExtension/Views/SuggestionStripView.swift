import SwiftUI

struct SuggestionStripView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        ZStack {
            if viewModel.activePopupKeyId != nil && !viewModel.activePopupVariants.isEmpty {
                // Clickable Long-Press Character Bar (also clickable directly in the strip!)
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
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(idx == viewModel.selectedVariantIndex ? .white : Color(hex: theme.textPrimaryHex))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 3)
                                        .background(idx == viewModel.selectedVariantIndex ? Color(hex: theme.accentColorHex) : Color(hex: theme.keyColorHex))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }

                    Spacer()

                    Button {
                        viewModel.dismissPopup()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: theme.textSecondaryHex))
                    }
                }
                .padding(.horizontal, 8)
            } else {
                // Centered 3-Column Android Gboard Suggestion Strip
                HStack(spacing: 0) {
                    if let calcResult = viewModel.calculatedMathResult {
                        Button {
                            viewModel.triggerHaptic()
                            viewModel.insertText(calcResult)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "equal.circle.fill")
                                    .foregroundColor(.green)
                                Text(calcResult)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(hex: theme.keyColorHex).opacity(0.6))
                            .cornerRadius(6)
                        }
                        .padding(.horizontal, 4)
                    }

                    ForEach(Array(viewModel.suggestions.enumerated()), id: \.offset) { idx, word in
                        Button {
                            viewModel.applySuggestion(word)
                        } label: {
                            Text(word)
                                .font(.system(size: 14, weight: idx == 0 ? .semibold : .regular))
                                .foregroundColor(Color(hex: theme.textPrimaryHex))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }

                        if idx < viewModel.suggestions.count - 1 {
                            Rectangle()
                                .fill(Color(hex: theme.textSecondaryHex).opacity(0.25))
                                .frame(width: 1, height: 16)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(height: 30)
    }
}
