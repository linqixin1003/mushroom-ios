
import SwiftUI

struct AppPage<Content>: View where Content: View {
    let title: String
    let leftButtonConfig: AppNavigationButtonConfig?
    let rightButtonConfig: AppNavigationButtonConfig?
    let content: () -> Content
    
    init(title: String,
         leftButtonConfig: AppNavigationButtonConfig? = nil,
         rightButtonConfig: AppNavigationButtonConfig? = nil,
         @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.leftButtonConfig = leftButtonConfig
        self.rightButtonConfig = rightButtonConfig
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // 内容区域
            VStack(spacing: 0) {
                // 添加导航栏高度的空白，确保内容不会被导航栏覆盖
                Spacer()
                    .frame(height: SafeNavigationBarHeight)
                content()
            }
            .zIndex(0)
            
            // 导航栏始终在最上层
            AppNavigationBar(
                title: self.title,
                leftButtonConfig: self.leftButtonConfig,
                rightButtonConfig: self.rightButtonConfig
            )
            .zIndex(1)
        }
        .ignoresSafeArea()
    }
}
