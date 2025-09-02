import SwiftUI


// 可展开的文本组件
struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    @State private var isExpanded: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(text)
                .font(.regular(13.rpx))
                .lineSpacing(2.rpx)
                .foregroundColor(.gray.opacity(0.8))
                .lineLimit(isExpanded ? nil : lineLimit)
                .animation(.easeInOut, value: isExpanded)

            if !isExpanded && needsExpansion {
                // "More >>" 按钮右下角悬挂显示
                Button(action: {
                    isExpanded = true
                }) {
                    HStack {
                        Text("...")
                            .font(.regular(12.rpx))
                            .lineSpacing(2.rpx)
                            .foregroundColor(.gray.opacity(0.8))
                        Text(Language.mushroom_info_more)
                            .font(.regular(12.rpx))
                            .lineSpacing(2.rpx)
                            .foregroundColor(.primary)
                            .padding(.trailing, 2)
                    }
                    .background(Color.white)
                }
            }
        }
    }
    
    private var needsExpansion: Bool {
        // 如果文本长度超过150个字符，就需要展开功能
        return text.count > 150
    }
}
