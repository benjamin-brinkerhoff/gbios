import UIKit
import SwiftUI
final class UnicodeCharCell: UICollectionViewCell {
    static let reuseId = "UnicodeCharCell"
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8.0
        contentView.layer.cornerCurve = .continuous
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
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
            contentView.alpha = isHighlighted ? 0.55 : 1.0
        }
    }
}
struct NativeUnicodeCollectionView: UIViewRepresentable {
    let characters: [String]
    let keyBgColor: UIColor
    let textColor: UIColor
    let onSelect: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 2, left: 6.5, bottom: 4, right: 6.5)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = true
        cv.alwaysBounceVertical = true
        cv.delaysContentTouches = false
        cv.canCancelContentTouches = true
        cv.register(UnicodeCharCell.self, forCellWithReuseIdentifier: UnicodeCharCell.reuseId)
        cv.dataSource = context.coordinator
        cv.delegate = context.coordinator
        return cv
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        let changed = context.coordinator.parent.characters != characters
        context.coordinator.parent = self
        if changed {
            uiView.setContentOffset(.zero, animated: false)
            uiView.reloadData()
        }
    }
    
    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: NativeUnicodeCollectionView
        
        init(_ parent: NativeUnicodeCollectionView) {
            self.parent = parent
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.characters.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UnicodeCharCell.reuseId, for: indexPath) as! UnicodeCharCell
            cell.label.text = parent.characters[indexPath.item]
            cell.label.textColor = parent.textColor
            cell.contentView.backgroundColor = parent.keyBgColor
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let char = parent.characters[indexPath.item]
            parent.onSelect(char)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let totalWidth = collectionView.bounds.width - 13.0 - (7.0 * 5.0)
            let w = max(36.0, floor(totalWidth / 8.0))
            return CGSize(width: w, height: 38.0)
        }
    }
}
struct UnicodeSymbolsView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared
    @State private var selectedCategoryId: String = "common"
    
    private let catalog = UnicodeCatalog.shared
    var theme: KeyboardTheme { settings.currentTheme }
    
    private var currentCharacters: [String] {
        catalog.categories.first(where: { $0.id == selectedCategoryId })?.characters ?? catalog.categories[0].characters
    }
    
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
            
            NativeUnicodeCollectionView(
                characters: currentCharacters,
                keyBgColor: UIColor(Color(hex: theme.keyColorHex)),
                textColor: UIColor(Color(hex: theme.textPrimaryHex)),
                onSelect: { char in
                    viewModel.triggerTouchDownFeedback()
                    viewModel.insertText(char)
                }
            )
            .frame(height: 138)
            
            HStack(spacing: 6.0) {
                KeyButtonView(
                    key: KeyModel(id: "uni_abc", primaryText: "ABC", type: .alphabeticToggle),
                    viewModel: viewModel
                )
                .frame(width: 42.0)
                
                KeyButtonView(
                    key: KeyModel(id: "uni_123", primaryText: "123", type: .symbolToggle),
                    viewModel: viewModel
                )
                .frame(width: 42.0)
                
                KeyButtonView(
                    key: KeyModel(id: "uni_space", primaryText: "space", type: .spacebar),
                    viewModel: viewModel
                )
                .frame(maxWidth: .infinity)
                
                KeyButtonView(
                    key: KeyModel(
                        id: "uni_period",
                        primaryText: ".",
                        alternateVariants: ["?", "!", ",", "'", "\"", "-", ";", ":", "/", "@", "(", ")", "…", "&", "%", "$", "#"],
                        type: .character(".")
                    ),
                    viewModel: viewModel
                )
                .frame(width: 34.0)
                
                KeyButtonView(
                    key: KeyModel(id: "uni_backspace", primaryText: "delete", type: .backspace),
                    viewModel: viewModel
                )
                .frame(width: 42.0)
                
                KeyButtonView(
                    key: KeyModel(id: "uni_return", primaryText: "return", type: .returnKey),
                    viewModel: viewModel
                )
                .frame(width: 58.0)
            }
            .padding(.horizontal, 6.5)
        }
    }
}
