import SwiftUI

struct ClipboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var clipboard = ClipboardStore.shared
    @StateObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("📋 Gboard Clipboard")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                Spacer()
                Button("Done") {
                    viewModel.activeDrawer = .none
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: theme.accentColorHex))
            }
            .padding(.horizontal, 10)

            if clipboard.items.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: theme.textSecondaryHex))
                    Text("Copied items will appear here.")
                        .font(.caption)
                        .foregroundColor(Color(hex: theme.textSecondaryHex))
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(clipboard.items) { clip in
                            Button {
                                viewModel.triggerHaptic()
                                viewModel.insertText(clip.text)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(clip.previewText)
                                            .font(.system(size: 13))
                                            .lineLimit(2)
                                            .foregroundColor(Color(hex: theme.textPrimaryHex))
                                        Spacer()
                                        if clip.isPinned {
                                            Image(systemName: "pin.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    Text(clip.formattedTime)
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(hex: theme.textSecondaryHex))
                                }
                                .padding(8)
                                .frame(width: 140, height: 60)
                                .background(Color(hex: theme.keyColorHex))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
        .frame(height: 120)
        .background(Color(hex: theme.functionalKeyColorHex))
    }
}
