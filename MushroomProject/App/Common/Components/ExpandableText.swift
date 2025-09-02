import SwiftUI

struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    
    @State private var expanded = false
    @State private var truncated = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.rpx) {
            Text(text)
                .font(.regular(14.rpx))
                .lineSpacing(4.rpx)
                .foregroundColor(.appTextLight)
                .lineLimit(expanded ? nil : lineLimit)
                .background(
                    // 隐藏的文本用于检测是否被截断
                    Text(text)
                        .font(.regular(14.rpx))
                        .lineSpacing(4.rpx)
                        .lineLimit(lineLimit)
                        .background(GeometryReader { visibleTextGeometry in
                            Color.clear.onAppear {
                                let size = CGSize(width: visibleTextGeometry.size.width, height: .greatestFiniteMagnitude)
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 14)
                                ]
                                let attributedText = NSAttributedString(string: text, attributes: attributes)
                                let fullTextRect = attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
                                truncated = fullTextRect.size.height > visibleTextGeometry.size.height
                            }
                        })
                        .hidden()
                )
            
            if truncated && !expanded {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        expanded = true
                    }
                }) {
                    HStack(spacing: 4.rpx) {
                        Text(Language.text_more)
                            .font(.regular(14.rpx))
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12.rpx, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            } else if expanded {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        expanded = false
                    }
                }) {
                    HStack(spacing: 4.rpx) {
                        Text(Language.text_less)
                            .font(.regular(14.rpx))
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12.rpx, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}