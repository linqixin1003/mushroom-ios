import SwiftUI
import Combine

let NavBarHeight: CGFloat = 44.0

struct AppNavigationButtonConfig {
    let imageName: String
    let onClick: () -> Void
}

struct AppNavigationBar: View {
    let title: String
    let leftButtonConfig: AppNavigationButtonConfig?
    let rightButtonConfig: AppNavigationButtonConfig?
    
    init(title: String, leftButtonConfig: AppNavigationButtonConfig? = nil, rightButtonConfig: AppNavigationButtonConfig? = nil) {
        self.title = title
        self.leftButtonConfig = leftButtonConfig
        self.rightButtonConfig = rightButtonConfig
    }
    
    // 导航栏高度
    private let navBarHeight: CGFloat = 44.0
    // 按钮尺寸
    private let buttonSize: CGFloat = 44.0
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧按钮
            if let leftButtonConfig {
                Button(action: {
                    leftButtonConfig.onClick()
                }) {
                    Image(leftButtonConfig.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: buttonSize, height: buttonSize)
                        .contentShape(Rectangle())
                        .background(Color.clear) // 确保背景是透明的，但可点击
                }
                .buttonStyle(PlainButtonStyle()) // 使用PlainButtonStyle以确保点击区域正确
            } else {
                Spacer()
                    .frame(width: buttonSize, height: buttonSize)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .lineLimit(1)
            
            Spacer()
            
            if let rightButtonConfig {
                Button(action: {
                    rightButtonConfig.onClick()
                }) {
                    // 检查是否为系统图标
                    if rightButtonConfig.imageName.contains("icon_") {
                        Image(rightButtonConfig.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .frame(width: buttonSize, height: buttonSize)
                            .contentShape(Rectangle())
                    } else {
                        Image(systemName: rightButtonConfig.imageName)
                            .frame(width: buttonSize, height: buttonSize)
                            .contentShape(Rectangle())
                    }
                }
                .buttonStyle(PlainButtonStyle()) // 使用PlainButtonStyle以确保点击区域正确
            } else {
                Spacer()
                    .frame(width: buttonSize, height: buttonSize)
            }
        }
        .padding(.top, SafeTop)
        .frame(height: SafeNavigationBarHeight)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.95)) // 使用半透明背景
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3))
                .position(x: UIScreen.main.bounds.width / 2, y: SafeNavigationBarHeight)
        )
    }
}

struct AppNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AppNavigationBar(
                title: "Title",
                leftButtonConfig: .init(imageName: "chevron.left", onClick: {}),
                rightButtonConfig: .init(imageName: "gear", onClick: {})
            )
            
            Spacer()
        }
    }
}
