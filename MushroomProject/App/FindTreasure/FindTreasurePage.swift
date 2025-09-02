import SwiftUI
import Foundation
import AVFoundation

struct FindTreasurePage: View {
    let magnitude: Double
    let onBack: () -> Void
    
    @State private var audioPlayer: AVAudioPlayer?
    
    // 计算百分比 (基于0-200范围映射到0-100%)
    // 计算百分比 (magnitude现在已经是0-100的百分比值)
    private var percentage: Int {
        let result = Int(max(0, min(magnitude, 100)))
        print("🔍 计算百分比 - magnitude: \(magnitude), percentage: \(result)")
        return result
    }
    
    var body: some View {
        ZStack {
            // 背景渐变 - 参考Android的米色背景
            Color(hex: 0xF0E6D6)
            
            VStack(spacing: 0) {
                // 顶部导航栏 - 参考Android TopAppBar设计
                VStack(spacing: 0) {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20.rpx, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                            .frame(width: 16.rpx)
                        
                        Text(Language.find_treasure_title)
                            .font(.system(size: 18.rpx, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16.rpx)
                    .frame(height: 44.rpx)
                }
                .background(Color.white)
                
                Spacer()
                
                // 仪表盘区域
                ModernGaugeChart(
                    percentage: percentage,
                    magnitude: magnitude
                )
                .frame(height: 240.rpx)
                
                Spacer()
                // 提示区域 - 参考Android设计，背景铺满底部和两边
                VStack(spacing: 0) {
                    VStack(spacing: 24.rpx) {
                        // 提示标题
                        HStack(spacing: 8.rpx) {
                            Image("icon_metal_tips")
                                .font(.system(size: 24.rpx))
                                .foregroundColor(Color(hex: 0xD4A574))
                            
                            Text(Language.text_tips)
                                .font(.system(size: 18.rpx, weight: .medium))
                                .foregroundColor(Color(hex: 0xD4A574))
                            
                            Spacer()
                        }
                        Divider()
                        ScrollView(){
                            Text(Language.metal_detector_tips_content)
                                .font(.system(size: 15.rpx))
                                .foregroundColor(.black)
                                .lineSpacing(6.rpx)
                                .lineLimit(nil)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 32.rpx)
                    .padding(.top, 32.rpx)
                    .padding(.bottom, SafeBottom + 32.rpx)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 16.rpx)
                            .fill(Color.white)
                            .frame(height: 16.rpx)
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(maxHeight: .infinity)
                    }
                )
            }
        }
        .onChange(of: magnitude) { newValue in
            // 当检测强度达到75%时播放提示音和震动
            if newValue >= 75 {
                playBeepSound()
                triggerHapticFeedback()
            }
        }
    }
}
private func playBeepSound() {
    // 播放系统提示音
    AudioServicesPlaySystemSound(1057) // 系统滴滴声
}

private func triggerHapticFeedback() {
    // 触发震动反馈
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    impactFeedback.impactOccurred()
}
    
struct ModernGaugeChart: View {
    let percentage: Int
    let magnitude: Double
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                drawGauge(context: context, size: size)
            }
            
            // 中心数值显示
            VStack(spacing: 4.rpx) {
                Text("\(percentage)")
                    .font(.system(size: 64.rpx, weight: .bold))
                    .foregroundColor(Color(hex: 0xD4A574))
                
                Text(String(format: "%.1f μT", magnitude))
                    .font(.system(size: 14.rpx))
                    .foregroundColor(.gray)
            }
            .offset(y: 20.rpx) // 向下偏移以配合半圆设计
        }
    }
    
    private func drawGauge(context: GraphicsContext, size: CGSize) {
        let radius = size.width * 0.3
        let centerX = size.width / 2
        let centerY = (size.height + radius) / 2
        let center = CGPoint(x: centerX, y: centerY)
        let strokeWidth: CGFloat = 20.rpx
        
        // 绘制背景半圆弧
        let backgroundPath = Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(360),
                clockwise: false
            )
        }
        context.stroke(backgroundPath, with: .color(Color(hex: 0xE8D5C4)), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
        
        // 绘制进度弧
        let sweepAngle = Double(percentage) / 100.0 * 180.0
        let progressPath = Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(180 + sweepAngle),
                clockwise: false
            )
        }
        context.stroke(progressPath, with: .color(Color(hex: 0xD4A574)), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
        
        // 绘制起始点圆点
        let startPoint = CGPoint(
            x: center.x + radius * cos(.pi),
            y: center.y + radius * sin(.pi)
        )
        let startCircle = Path { path in
            path.addEllipse(in: CGRect(x: startPoint.x - 12.rpx, y: startPoint.y - 12.rpx, width: 24.rpx, height: 24.rpx))
        }
        context.fill(startCircle, with: .color(.white))
        
        // 绘制当前位置指示点
        let currentAngle = .pi + (sweepAngle * .pi / 180.0)
        let currentPoint = CGPoint(
            x: center.x + radius * cos(currentAngle),
            y: center.y + radius * sin(currentAngle)
        )
        
        // 外圆
        let outerCircle = Path { path in
            path.addEllipse(in: CGRect(x: currentPoint.x - 12.rpx, y: currentPoint.y - 12.rpx, width: 24.rpx, height: 24.rpx))
        }
        context.fill(outerCircle, with: .color(Color(hex: 0xD4A574)))
        
        // 内圆
        let innerCircle = Path { path in
            path.addEllipse(in: CGRect(x: currentPoint.x - 8.rpx, y: currentPoint.y - 8.rpx, width: 16.rpx, height: 16.rpx))
        }
        context.fill(innerCircle, with: .color(.white))
        
        // 绘制刻度线和标签
        let labels = ["0", "25", "50", "75", "100"]
        for i in 0..<5 {
            let tickAngle = .pi + Double(i) * .pi / 4
            
            // 刻度线
            let tickStartRadius = radius - 25.rpx
            let tickEndRadius = radius - 15.rpx
            
            let tickStart = CGPoint(
                x: center.x + tickStartRadius * cos(tickAngle),
                y: center.y + tickStartRadius * sin(tickAngle)
            )
            let tickEnd = CGPoint(
                x: center.x + tickEndRadius * cos(tickAngle),
                y: center.y + tickEndRadius * sin(tickAngle)
            )
            
            let tickPath = Path { path in
                path.move(to: tickStart)
                path.addLine(to: tickEnd)
            }
            context.stroke(tickPath, with: .color(Color(hex: 0xD4A574)), style: StrokeStyle(lineWidth: 2.rpx, lineCap: .round))
            
            // 标签
            let labelRadius = radius - 35.rpx
            let labelPosition = CGPoint(
                x: center.x + labelRadius * cos(tickAngle),
                y: center.y + labelRadius * sin(tickAngle)
            )
            
            context.draw(
                Text(labels[i])
                    .font(.system(size: 14.rpx))
                    .foregroundColor(Color(hex: 0xD4A574)),
                at: labelPosition
            )
        }
    }
}
