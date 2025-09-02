import SwiftUI
import Combine
import Kingfisher

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct ActionMenuView: View {
    var onShare: () -> Void
    var onDelete: () -> Void
    @State private var isMenuPresented = false
    
    var body: some View {
        Menu {
            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .foregroundColor(.gray)
                .frame(width: 24, height: 24)
                .overlay(alignment: .top) {
                    if isMenuPresented {
                        TriangleShape()
                            .fill(Color.white)
                            .frame(width: 10, height: 5)
                            .offset(y: -10)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
        }
        .onTapGesture {
            withAnimation {
                isMenuPresented.toggle()
            }
        }
    }
}

struct CollectionItemView: View {
    let model: LocalRecordItem
    var onDelete: ((LocalRecordItem) -> Void)?
    var onShare: ((LocalRecordItem) -> Void)?
    var onItemClick: ((LocalRecordItem) -> Void)?
    @State private var isPlaying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 媒体内容区域
            mediaContent
                .onTapGesture {
                    onItemClick?(model)
                }
            
            // 信息区域
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.commonName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    HStack(alignment: .center, spacing: 4) {
                        Text(formattedDate(model.createdAt))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()                        
                        // 使用新的ActionMenuView
                        ActionMenuView(
                            onShare: {
                                onShare?(model)
                            },
                            onDelete: {
                                onDelete?(model)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    
    }
    
    // 媒体内容视图
    private var mediaContent: some View {
        ZStack(alignment: .topTrailing) {
            // 图片类型
            KFImage
                .url(URL(string: model.mediaUrl))
                .placeholder {
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                }
                .resizable()
                .aspectRatio(160/182, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipped()
                .background(Color.gray.opacity(0.1))
        }
    }
    
    // 时间格式化
    private func formattedDate(_ isoString: String) -> String {
        if let date = ISO8601DateFormatter().date(from: isoString) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        return String(isoString.prefix(10))
    }
}

struct LazyVGridFooter: View {
    var body: some View {
        HStack {
            Spacer()
                            Text(Language.my_collection_no_more)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 24)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// 自定义 Shape 用于只设置部分圆角
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ActionMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ActionMenuView(
            onShare: { print("Share") },
            onDelete: { print("Delete") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

struct AddMoreCardView: View {
    var onTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            // 整个卡片的背景色
            Color.gray.opacity(0.08)
                .aspectRatio(160/240, contentMode: .fit)
            
            // 加号图标
            Image(systemName: "plus")
                .font(.system(size: 60, weight: .ultraLight))
                .foregroundColor(.gray.opacity(0.5))
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap?()
        }
    }
}


