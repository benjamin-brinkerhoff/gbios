import SwiftUI

struct OneHandedContainerView<Content: View>: View {
    @StateObject private var settings = KeyboardSettings.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 0) {
            if settings.oneHandedModeRaw == "right" {
                VStack(spacing: 16) {
                    Button { settings.oneHandedModeRaw = "none" } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    Button { settings.oneHandedModeRaw = "left" } label: {
                        Image(systemName: "chevron.left.2")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 44)
            }

            content
                .frame(maxWidth: settings.oneHandedModeRaw == "none" ? .infinity : 320)

            if settings.oneHandedModeRaw == "left" {
                VStack(spacing: 16) {
                    Button { settings.oneHandedModeRaw = "none" } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    Button { settings.oneHandedModeRaw = "right" } label: {
                        Image(systemName: "chevron.right.2")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 44)
            }
        }
    }
}
