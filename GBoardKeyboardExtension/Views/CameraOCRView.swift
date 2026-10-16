import SwiftUI
import Vision
import AVFoundation

struct CameraOCRView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared
    @State private var recognizedText: String = ""
    @State private var isScanning: Bool = false

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("📷 Scan Text (OCR)")
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

            VStack(spacing: 8) {
                Text("Align camera over printed text to extract directly into input.")
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.textSecondaryHex))

                Button {
                    viewModel.triggerHaptic()
                    // Insert sample extracted OCR text or trigger OCR session
                    viewModel.insertText("Scanned Text from Camera ")
                    viewModel.activeDrawer = .none
                } label: {
                    Label("Insert Scanned Text", systemImage: "text.viewfinder")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: theme.accentColorHex))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 150)
        .background(Color(hex: theme.functionalKeyColorHex))
    }
}
