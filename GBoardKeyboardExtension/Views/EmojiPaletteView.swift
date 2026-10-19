import SwiftUI

struct EmojiPaletteView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared
    @ObservedObject private var catalog = EmojiCatalog.shared

    @State private var selectedTabId: String = "recents"
    @State private var searchQuery: String = ""
    @State private var isSearching: Bool = false

    var theme: KeyboardTheme { settings.currentTheme }

    private let gridRows = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)
    private let miniSearchKeys = ["q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m"]

    private var displayedEmojis: [String] {
        if !searchQuery.isEmpty {
            return catalog.searchEmojis(query: searchQuery)
        }
        if selectedTabId == "recents" {
            return catalog.recentEmojis
        }
        return catalog.categories.first(where: { $0.id == selectedTabId })?.emojis ?? catalog.recentEmojis
    }

    private var navItems: [(id: String, icon: String)] {
        [
            ("recents", "clock"),
            ("smileys", "face.smiling"),
            ("animals", "pawprint"),
            ("food", "fork.knife"),
            ("activity", "soccerball"),
            ("travel", "car"),
            ("objects", "lightbulb"),
            ("symbols", "heart"),
            ("flags", "flag")
        ]
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.55))

                Text(searchQuery.isEmpty ? "Search Emoji" : searchQuery)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(searchQuery.isEmpty ? Color.white.opacity(0.48) : Color(hex: theme.textPrimaryHex))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !searchQuery.isEmpty || isSearching {
                    Button {
                        viewModel.triggerTouchDownFeedback()
                        if !searchQuery.isEmpty {
                            searchQuery = ""
                        } else {
                            isSearching = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(Color.white.opacity(0.55))
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 35)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(theme.isDark ? 0.14 : 0.65))
            )
            .padding(.horizontal, 8)
            .onTapGesture {
                viewModel.triggerTouchDownFeedback()
                isSearching.toggle()
            }

            if isSearching {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(miniSearchKeys, id: \.self) { k in
                            Button {
                                viewModel.triggerTouchDownFeedback()
                                searchQuery.append(k)
                            } label: {
                                Text(k)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                                    .frame(width: 24, height: 28)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .fill(Color(hex: theme.keyColorHex))
                                    )
                            }
                        }
                        Button {
                            viewModel.triggerTouchDownFeedback()
                            if !searchQuery.isEmpty { searchQuery.removeLast() }
                        } label: {
                            Image(systemName: "delete.left")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: theme.textPrimaryHex))
                                .frame(width: 30, height: 28)
                                .background(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(Color(hex: theme.keyColorHex))
                                )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(height: 30)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridRows, spacing: 12) {
                    ForEach(displayedEmojis, id: \.self) { emoji in
                        Button {
                            viewModel.triggerTouchDownFeedback()
                            catalog.recordEmojiUsed(emoji)
                            viewModel.insertText(emoji)
                        } label: {
                            Text(emoji)
                                .font(.system(size: 32 * settings.emojiSizeFactor))
                                .frame(width: 42, height: 40)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(height: isSearching ? 142 : 176)

            HStack(spacing: 0) {
                Button {
                    viewModel.triggerTouchDownFeedback()
                    viewModel.activeDrawer = .none
                } label: {
                    Text("ABC")
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundColor(Color(hex: theme.textPrimaryHex).opacity(0.85))
                        .frame(width: 42, height: 32)
                }

                Spacer(minLength: 2)

                ForEach(navItems, id: \.id) { item in
                    let isSelected = (selectedTabId == item.id && searchQuery.isEmpty)
                    Button {
                        viewModel.triggerTouchDownFeedback()
                        searchQuery = ""
                        isSearching = false
                        selectedTabId = item.id
                    } label: {
                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(Color.white.opacity(theme.isDark ? 0.20 : 0.45))
                                    .frame(width: 30, height: 30)
                            }
                            Image(systemName: item.icon)
                                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(
                                    isSelected
                                        ? Color(hex: theme.textPrimaryHex)
                                        : Color(hex: theme.textPrimaryHex).opacity(0.55)
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                    }
                }

                Spacer(minLength: 2)

                KeyButtonView(
                    key: KeyModel(id: "emoji_backspace", primaryText: "delete", type: .backspace),
                    viewModel: viewModel,
                    showBackground: false
                )
                .frame(width: 40, height: 32)
            }
            .padding(.horizontal, 6)
            .frame(height: 34)
        }
    }
}
