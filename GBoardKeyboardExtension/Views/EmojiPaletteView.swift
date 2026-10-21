import UIKit
import SwiftUI
final class EmojiGridCell: UICollectionViewCell {
    static let reuseId = "EmojiGridCell"
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.transform = isHighlighted ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        }
    }
}
struct NativeEmojiCollectionView: UIViewRepresentable {
    let emojis: [String]
    let fontSize: CGFloat
    let onSelect: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        cv.delaysContentTouches = false
        cv.canCancelContentTouches = true
        cv.register(EmojiGridCell.self, forCellWithReuseIdentifier: EmojiGridCell.reuseId)
        cv.dataSource = context.coordinator
        cv.delegate = context.coordinator
        return cv
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        let changed = context.coordinator.parent.emojis != emojis
        context.coordinator.parent = self
        if changed {
            uiView.setContentOffset(.zero, animated: false)
            uiView.reloadData()
        }
    }
    
    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: NativeEmojiCollectionView
        
        init(_ parent: NativeEmojiCollectionView) {
            self.parent = parent
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.emojis.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiGridCell.reuseId, for: indexPath) as! EmojiGridCell
            cell.label.text = parent.emojis[indexPath.item]
            cell.label.font = UIFont.systemFont(ofSize: parent.fontSize)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            parent.onSelect(parent.emojis[indexPath.item])
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let h = max(34.0, floor((collectionView.bounds.height - 16.0) / 4.0))
            return CGSize(width: 44.0, height: h)
        }
    }
}
struct EmojiPaletteView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared
    @ObservedObject private var catalog = EmojiCatalog.shared
    
    @State private var selectedTabId: String = "recents"
    @State private var searchQuery: String = ""
    @State private var isSearching: Bool = false
    
    var theme: KeyboardTheme { settings.currentTheme }
    
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
            
            NativeEmojiCollectionView(
                emojis: displayedEmojis,
                fontSize: CGFloat(32.0 * settings.emojiSizeFactor),
                onSelect: { emoji in
                    viewModel.triggerTouchDownFeedback()
                    catalog.recordEmojiUsed(emoji)
                    viewModel.insertText(emoji)
                }
            )
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
