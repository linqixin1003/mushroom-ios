import SwiftUI

enum HomeActionType: CaseIterable, Identifiable {
    case Valuation
    case Identify
    case Detector
    
    var title: String {
        switch self {
        case .Valuation:
            return LocalizationManager.shared.localizedString(for: "home_action_type_valuation")
        case .Identify:
            return LocalizationManager.shared.localizedString(for: "home_action_type_identify")
        case .Detector:
            return LocalizationManager.shared.localizedString(for: "home_action_type_detector")
        }
    }
    
    var icon: String {
        switch self {
        case .Valuation:
            return "icon_home_action_record"
        case .Identify:
            return "icon_home_action_identify"
        case .Detector:
            return "icon_home_action_ai_beauty"
        }
    }
    
    var id: String {
        return self.title
    }
}

struct HomeActionView: View {
    
    let onItemClick: (HomeActionType) -> Void
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        HStack(spacing: 12.rpx) {
            ForEach(HomeActionType.allCases) { type in
                HomeActionButton(
                    type: type,
                    onItemClick: onItemClick
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct HomeActionButton: View {
    let type: HomeActionType
    let onItemClick: (HomeActionType) -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            onItemClick(type)
        }) {
            HomeActionItemView(
                icon: type.icon,
                title: type.title
            )
        }
        .buttonStyle(CustomButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct HomeActionItemView: View {
    
    let icon: String
    let title: String
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 2.rpx) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 48.rpx, height: 48.rpx)
            
            Text(title)
                .font(.system(size: 12.rpx, weight: .semibold))
                .lineSpacing(2.rpx)
                .foregroundColor(Color(hex: 0x131C1B))
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 12.rpx)
        .padding(.vertical, 16.rpx)
        .frame(maxWidth: .infinity)
        .frame(height: 100.rpx)
        .background(Color.white)
        .cornerRadius(12.rpx)
    }
}