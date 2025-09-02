import SwiftUI

struct WishListItemView: View {
    let item: LocalWishListItem
    let onDelete: (LocalWishListItem) -> Void
    let onShare: (LocalWishListItem) -> Void
    let onItemClick: (LocalWishListItem) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 图片区域
            AsyncImage(url: URL(string: item.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 120)
            .clipped()
            .onTapGesture {
                onItemClick(item)
            }
            
            // 信息区域
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Spacer()
                    
                    // 稀有度标签
                    if let rarity = item.rarity, !rarity.isEmpty {
                        Text(rarity)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                }
                
                // 估值信息
                if let estimatedValue = item.estimatedValue, !estimatedValue.isEmpty {
                    Text("\(Language.stone_estimated_value): \(estimatedValue)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                // 描述
                Text(item.description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // 操作按钮
                HStack {
                    Button(action: {
                        onShare(item)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0x00A796))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onDelete(item)
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// 预览
struct WishListItemView_Previews: PreviewProvider {
    static var previews: some View {
        WishListItemView(
            item: LocalWishListItem(
                id: "1",
                stoneId: "stone_001",
                name: "Amethyst",
                imageUrl: "https://example.com/amethyst.jpg",
                description: "A beautiful purple quartz with high collectible value.",
                estimatedValue: "$100-200",
                rarity: "Rare",
                createdAt: "2024-01-15T10:30:00Z"
            ),
            onDelete: { _ in },
            onShare: { _ in },
            onItemClick: { _ in }
        )
        .frame(width: 160)
        .previewLayout(.sizeThatFits)
    }
}