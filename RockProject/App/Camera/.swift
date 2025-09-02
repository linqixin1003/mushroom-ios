import AVFoundation
import SwiftUI
import AVFoundation

class RecordViewModel: ObservableObject {
    private let SAMPLING_PROPORTION = 600
    @Published var audioIsAuthorized = false
    @Published var isRecording:Bool = false
    private var recorderConductor: RecorderConductor = RecorderConductor()
    
    func checkMicrophoneAuthorization() {
        let audioSession = AVAudioSession.sharedInstance()
        switch audioSession.recordPermission {
        case .granted:
            self.audioIsAuthorized = true
            startRecorderEngine()
        case .denied:
            self.audioIsAuthorized = false
        case .undetermined:
            requestMicrophoneAccess()
        @unknown default:
            self.audioIsAuthorized = false
        }
    }

    func requestMicrophoneAccess() {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.startRecorderEngine()
                self.audioIsAuthorized = granted
            }
        }
    }
    
    private var recordStartSampleTime: AVAudioFramePosition?
    @Published var time = "00:00:00"
    @Published var waveData:[Float] = []
    private var tempData:[Float] = []
    private func timeTooShort()->Bool {
        return time < "00:05:00"
    }
    
    func startRecord(onComlete: @escaping (AVAudioFile) -> Void){
        print("[RecordViewMode] startRecord isRecording=\(isRecording), audioIsAuthorized = \(audioIsAuthorized)")
        self.isRecording = true
        self.recorderConductor.start { data, t in
            if self.recordStartSampleTime == nil {
                self.recordStartSampleTime = t.sampleTime // 录音起点
                DispatchQueue.main.async {
                    self.waveData = []
                    self.tempData = []
                }
            }
            
            if let startSample = self.recordStartSampleTime {
                self.tempData.append(contentsOf: data)
                let group = self.tempData.count / self.SAMPLING_PROPORTION
                if group >= 1 {
                    let getCount = group * self.SAMPLING_PROPORTION
                    let dealData = Array(self.tempData.prefix(getCount))
                    self.tempData.removeFirst(getCount)
                    self.waveData.append(contentsOf: self.groupedRMS(data: dealData, groupSize: self.SAMPLING_PROPORTION))
                }
                let elapsedSamples = t.sampleTime - startSample
                let elapsedSeconds = Double(elapsedSamples) / t.sampleRate
                print("Recording duration: \(elapsedSeconds) seconds, data.size = \(data.count)")
                let millTotalSecond = elapsedSeconds * 1000
                if millTotalSecond.isFinite && !millTotalSecond.isNaN {
                    let millTotalSecondInt = Int(millTotalSecond)
                    let TotalSecondInt = millTotalSecondInt / 1000
                    let minutes = TotalSecondInt / 60
                    let seconds = TotalSecondInt % 60
                    let milliseconds = (millTotalSecondInt % 1000) / 10
                    DispatchQueue.main.async {
                        self.time = String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.time = "00:00:00"
                    }
                }
                if self.time > "00:30:00" {
                    self.stopRecord(onComlete: onComlete)
                }
            }
        }
    }
    
    func stopRecord(forceStop:Bool = false, onComlete: (AVAudioFile) -> Void){
        print("[RecordViewMode] stopRecord forceStop=\(forceStop), time = \(time), isRecording = \(isRecording)")
        if self.isRecording && self.timeTooShort() && !forceStop {
            ToastUtil.showToast("Please record at least 5 seconds")
            return
        }
        self.recorderConductor.stop()
        self.recordStartSampleTime = nil
        self.isRecording = false
        self.time = "00:00:00"
        if let audioFile = self.recorderConductor.recorder?.audioFile{
            if !forceStop {
                onComlete(audioFile)
            }
        }
    }
    
    private func groupedRMS(data: [Float], groupSize: Int) -> [Float] {
        guard groupSize > 0, !data.isEmpty else { return [] }
        var result: [Float] = []
        let scale: Float = 6.0      // 放大系数，可调
        let power: Float = 0.5      // 幂次（0.5=sqrt，<1拉大动态范围）
        let minShow: Float = 0.08   // 可调，最小显示高度
        
        for i in stride(from: 0, to: data.count, by: groupSize) {
            let end = min(i + groupSize, data.count)
            let slice = data[i..<end]
            // RMS: sqrt(平均的平方)
            let meanSquare = slice.reduce(0.0) { $0 + $1 * $1 } / Float(slice.count)
            let rms = sqrt(meanSquare)
            // 可视化处理
            var visualRMS = pow(rms * scale, power)
            // 限制范围
            if visualRMS > 1.0 { visualRMS = 1.0 }
            if visualRMS < minShow { visualRMS = minShow }
            result.append(visualRMS)
        }
        return result
    }
    
    func startRecorderEngine() {
        print("[RecordViewMode] startRecorderEngine")
        self.recorderConductor.start()
    }
    
    func stopRecorderEngine() {
        print("[RecordViewMode] stopRecorderEngine")
        self.recorderConductor.stop()
        self.stopRecord(forceStop: true){ _ in}
    }
}
