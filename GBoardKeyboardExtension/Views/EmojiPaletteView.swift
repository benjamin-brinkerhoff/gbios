import SwiftUI

struct EmojiPaletteView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    let emojis: [String] = [
        "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "🥲", "☺️",
        "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗",
        "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🥸",
        "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "☹️",
        "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😮‍💨", "😤", "😠",
        "👍", "👎", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✌️", "🤞",
        "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔",
        "🔥", "✨", "🎉", "🚀", "💡", "💯", "⭐", "🌟", "⚡", "🌈"
    ]

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Emojis")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                Spacer()
                Button("ABC") {
                    viewModel.activeDrawer = .none
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: theme.accentColorHex))
            }
            .padding(.horizontal, 10)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            viewModel.triggerHaptic()
                            viewModel.insertText(emoji)
                        } label: {
                            Text(emoji)
                                .font(.system(size: 28 * settings.emojiSizeFactor))
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .frame(height: 210)
        .background(Color(hex: theme.functionalKeyColorHex))
    }
}
