import SwiftUI

struct KeyPopupBubbleView: View {
    let variants: [String]
    let selectedIndex: Int
    let theme: KeyboardTheme
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(variants.prefix(7).enumerated()), id: \.offset) { index, v in
                let isSelected = (index == selectedIndex)
                Button {
                    onSelect(v)
                } label: {
                    Text(v)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isSelected ? .white : Color(hex: theme.textPrimaryHex))
                        .frame(minWidth: 28, minHeight: 34)
                        .padding(.horizontal, 4)
                        .background(isSelected ? Color(hex: theme.accentColorHex) : Color(hex: theme.keyColorHex))
                        .cornerRadius(7)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(Color(hex: theme.functionalKeyColorHex))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: theme.accentColorHex).opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}
