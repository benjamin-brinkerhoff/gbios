import SwiftUI

struct KeyPopupBubbleView: View {
    let primary: String
    let variants: [String]
    let theme: KeyboardTheme

    var body: some View {
        HStack(spacing: 6) {
            ForEach(variants.prefix(6), id: \.self) { v in
                Text(v)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                    .frame(width: 28, height: 34)
                    .background(Color(hex: theme.keyColorHex))
                    .cornerRadius(6)
            }
        }
        .padding(6)
        .background(Color(hex: theme.functionalKeyColorHex))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
}
