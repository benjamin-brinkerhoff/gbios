import SwiftUI

struct UnicodeSymbolsView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared
    @State private var selectedCategoryId: String = "common"

    private let catalog = UnicodeCatalog.shared
    var theme: KeyboardTheme { settings.currentTheme }
    var isLiquidGlass: Bool { settings.useNativeIOSLayout || theme.useFrostedGlass }
    var cornerRadius: CGFloat { settings.keycapStyle.cornerRadius }

    private var currentCharacters: [String] {
        catalog.categories.first(where: { $0.id == selectedCategoryId })?.characters ?? catalog.categories[0].characters
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 8)

    var body: some View {
        VStack(spacing: 4) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(catalog.categories) { cat in
                        let isSelected = (cat.id == selectedCategoryId)
                        Button {
                            viewModel.triggerTouchDownFeedback()
                            selectedCategoryId = cat.id
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: cat.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(cat.title)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected ? Color(hex: theme.accentColorHex) : Color(hex: theme.keyColorHex))
                            )
                            .foregroundColor(isSelected ? .white : Color(hex: theme.textPrimaryHex))
                        }
                    }
                }
                .padding(.horizontal, 6.5)
            }
            .frame(height: 30)

            ScrollView(.vertical, showsIndicators: true) {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(currentCharacters, id: \.self) { char in
                        Button {
                            viewModel.triggerTouchDownFeedback()
                            viewModel.insertText(char)
                        } label: {
                            Text(char)
                                .font(.system(size: 19, weight: .regular))
                                .foregroundColor(Color(hex: theme.textPrimaryHex))
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(
                                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                        .fill(Color(hex: theme.keyColorHex))
                                )
                        }
                    }
                }
                .padding(.horizontal, 6.5)
                .padding(.vertical, 2)
            }
            .frame(height: 138)

            HStack(spacing: 6.0) {
                KeyButtonView(
                    key: KeyModel(id: "uni_abc", primaryText: "ABC", type: .alphabeticToggle),
                    viewModel: viewModel
                )
                .frame(width: 44.0)

                KeyButtonView(
                    key: KeyModel(id: "uni_123", primaryText: "123", type: .symbolToggle),
                    viewModel: viewModel
                )
                .frame(width: 44.0)

                KeyButtonView(
                    key: KeyModel(id: "uni_space", primaryText: "space", type: .spacebar),
                    viewModel: viewModel
                )
                .frame(maxWidth: .infinity)

                KeyButtonView(
                    key: KeyModel(id: "uni_backspace", primaryText: "delete", type: .backspace),
                    viewModel: viewModel
                )
                .frame(width: 44.0)

                KeyButtonView(
                    key: KeyModel(id: "uni_return", primaryText: "return", type: .returnKey),
                    viewModel: viewModel
                )
                .frame(width: 64.0)
            }
            .padding(.horizontal, 6.5)
        }
    }
}
