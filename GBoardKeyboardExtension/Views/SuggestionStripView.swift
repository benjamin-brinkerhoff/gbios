import SwiftUI

struct SuggestionStripView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        HStack(spacing: 8) {
            // GboardWu Inline Calculator result chip
            if let calcResult = viewModel.calculatedMathResult {
                Button {
                    viewModel.triggerHaptic()
                    viewModel.insertText(calcResult)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "equal.circle.fill")
                            .foregroundColor(.green)
                        Text(calcResult)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: theme.textPrimaryHex))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: theme.keyColorHex))
                    .cornerRadius(8)
                }
            }

            // Predictive suggestion chips (PixelBoard style)
            SuggestionChip(text: "the", theme: theme) { viewModel.insertText("the ") }
            SuggestionChip(text: "I", theme: theme) { viewModel.insertText("I ") }
            SuggestionChip(text: "to", theme: theme) { viewModel.insertText("to ") }

            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
    }
}

struct SuggestionChip: View {
    let text: String
    let theme: KeyboardTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: theme.textPrimaryHex))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(hex: theme.keyColorHex))
                .cornerRadius(6)
        }
    }
}
