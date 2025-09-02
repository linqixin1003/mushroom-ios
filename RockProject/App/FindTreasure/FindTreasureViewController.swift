import UIKit
import SwiftUI
import CoreMotion
import AudioToolbox
import AVFoundation

class FindTreasureViewController: UIViewController {
    
    private let motionManager = CMMotionManager()
    private var magnitude: Double = 0.0
    private var baselineMagnitude: Double = 0.0
    private var relativeMagnitude: Double = 0.0
    private var calibrationSamples: [Double] = []
    private var isCalibrated: Bool = false
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var timer: Timer?
    
    // 用于设备方向补偿的变量
    private var recentMagnitudes: [Double] = []
    private let smoothingWindowSize = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 viewDidLoad - 初始 magnitude: \(magnitude)")
        setupUI()
        setupMagnetometer()
        startCalibration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCalibrated {
            startMagnetometerUpdates()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMagnetometerUpdates()
    }
    
    private var hostingController: UIHostingController<FindTreasurePage>?
    
    private func setupUI() {
        print("🔍 setupUI - 初始 magnitude: \(magnitude)")
        let hostingController = UIHostingController(rootView: FindTreasurePage(
            magnitude: magnitude,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        ))
        
        self.hostingController = hostingController
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
    
    private func setupMagnetometer() {
        guard motionManager.isMagnetometerAvailable else {
            print("❌ 磁力计不可用")
            return
        }
        
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ 设备运动数据不可用")
            return
        }
        
        motionManager.magnetometerUpdateInterval = 0.1 // 100ms更新间隔
        motionManager.deviceMotionUpdateInterval = 0.1
        print("🔍 磁力计和设备运动传感器设置完成")
    }
    
    private func startCalibration() {
        print("🔍 开始校准环境磁场...")
        calibrationSamples.removeAll()
        isCalibrated = false
        startMagnetometerUpdates()
    }
    
    private func startMagnetometerUpdates() {
        // 同时启动磁力计和设备运动数据
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] (motion, error) in
            guard let self = self, let deviceMotion = motion else { return }
            
            // 使用校准后的磁场数据（已经补偿了设备偏差和硬铁干扰）
            let calibratedField = deviceMotion.magneticField.field
            let x = calibratedField.x
            let y = calibratedField.y
            let z = calibratedField.z
            
            // 计算磁场强度的模
            let rawMagnitude = sqrt(x * x + y * y + z * z)
            
            // 数据平滑处理
            self.recentMagnitudes.append(rawMagnitude)
            if self.recentMagnitudes.count > self.smoothingWindowSize {
                self.recentMagnitudes.removeFirst()
            }
            
            let smoothedMagnitude = self.recentMagnitudes.reduce(0, +) / Double(self.recentMagnitudes.count)
            
            if !self.isCalibrated {
                // 校准阶段：收集基线数据
                self.calibrationSamples.append(smoothedMagnitude)
                print("🔍 校准中... 样本数: \(self.calibrationSamples.count)/30, 当前值: \(smoothedMagnitude) μT")
                
                if self.calibrationSamples.count >= 30 { // 收集30个样本
                    self.baselineMagnitude = self.calibrationSamples.reduce(0, +) / Double(self.calibrationSamples.count)
                    self.isCalibrated = true
                    print("🔍 校准完成 - 基线磁场强度: \(self.baselineMagnitude) μT")
                }
                return
            }
            
            // 计算相对于基线的磁场变化
            self.relativeMagnitude = abs(smoothedMagnitude - self.baselineMagnitude)
            
            // 将相对变化映射到0-100的范围
            // 假设20μT的变化对应100%的检测强度（降低敏感度）
            let maxDetectionRange: Double = 20.0
            let detectionPercentage = min(100.0, (self.relativeMagnitude / maxDetectionRange) * 100.0)
            self.magnitude = detectionPercentage
            
            print("🔍 校准磁场数据 - x: \(x), y: \(y), z: \(z)")
            print("🔍 平滑磁场强度: \(smoothedMagnitude) μT, 基线: \(self.baselineMagnitude) μT")
            print("🔍 相对变化: \(self.relativeMagnitude) μT, 检测强度: \(self.magnitude)%")
            
            // 更新UI
            self.updateUI()
            
            // 当检测强度达到75%时开始报警
            if self.magnitude >= 75 {
                self.triggerFeedback()
            }
        }
    }
    
    private func stopMagnetometerUpdates() {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopMagnetometerUpdates()
        timer?.invalidate()
        timer = nil
    }
    
    private func updateUI() {
        // 更新SwiftUI视图
        print("🔍 更新UI - magnitude: \(magnitude)")
        hostingController?.rootView = FindTreasurePage(
            magnitude: magnitude,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
    }
    
    private func triggerFeedback() {
        // 震动反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // 播放提示音
        playBeepSound()
    }
    
    private func playBeepSound() {
        // 使用系统音效
        AudioServicesPlaySystemSound(1057) // 短促的提示音
        
        // 或者播放自定义音频（如果需要更复杂的声音）
        // playCustomBeep()
    }
    
    private func playCustomBeep() {
        // 生成1000Hz的纯音，持续100毫秒
        let sampleRate: Double = 44100
        let duration: Double = 0.1
        let frequency: Double = 1000
        let numSamples = Int(sampleRate * duration)
        
        var samples: [Float] = []
        for i in 0..<numSamples {
            let sample = sin(2.0 * Double.pi * frequency * Double(i) / sampleRate) * 0.5
            samples.append(Float(sample))
        }
        
        // 使用AVAudioEngine播放生成的音频
        if audioEngine == nil {
            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            audioEngine?.attach(playerNode!)
            audioEngine?.connect(playerNode!, to: audioEngine!.mainMixerNode, format: nil)
            
            do {
                try audioEngine?.start()
            } catch {
                print("Audio engine start failed: \(error)")
            }
        }
        
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numSamples))!
        buffer.frameLength = AVAudioFrameCount(numSamples)
        
        for i in 0..<numSamples {
            buffer.floatChannelData?[0][i] = samples[i]
        }
        
        playerNode?.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !(playerNode?.isPlaying ?? false) {
            playerNode?.play()
        }
    }
    
    deinit {
        stopMagnetometerUpdates()
        audioEngine?.stop()
    }
}
