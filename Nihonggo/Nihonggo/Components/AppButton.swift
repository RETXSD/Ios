import SwiftUI

struct AppButton: View {
    enum Style {
        case primary
        case secondary
        case danger
    }

    let title: String
    let systemImage: String?
    let style: Style
    let action: () -> Void

    @State private var isPressed = false

    init(_ title: String, systemImage: String? = nil, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal)
                .foregroundStyle(foreground)
                .background(background)
                .overlay {
                    Capsule().stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
                }
                .clipShape(Capsule())
                .offset(y: isPressed ? 3 : 0)
                .flatShadow(collapsed: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(title)
    }

    private var background: Color {
        switch style {
        case .primary:
            return AppTheme.toriiRed
        case .secondary:
            return AppTheme.washiWhite
        case .danger:
            return AppTheme.sakuraBlush
        }
    }

    private var foreground: Color {
        style == .primary ? AppTheme.washiWhite : AppTheme.sumiInk
    }
}
