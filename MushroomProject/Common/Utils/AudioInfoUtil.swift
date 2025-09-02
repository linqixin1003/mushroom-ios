import Combine
import AVFoundation
import Waveform
import UIKit

class AudioInfoUtil{
    public static let COUNT = 80
    public static func loadSoundWave(sounds:[String], callBack: @escaping ([AudioInfo])->Void){
        Task {
            var soundData:[AudioInfo] = Array(repeating: AudioInfo(), count: sounds.count)
            for i in 0..<sounds.count {
                var tempData:[Float] = []
                var audioDuration:Double = 0
                // 这里可以添加循环内的具体逻辑
                if let soundUrl = URL(string:sounds[i]){
                    if let audioFile = loadAudioFileFromNetwork(url: soundUrl){
                        tempData = generateData(audioFile: audioFile)
                        if let tempDuration = getAudioDuration(from:audioFile){
                            audioDuration = tempDuration
                        }
                    }
                }
                
                soundData[i] = AudioInfo(duration:audioDuration, data:tempData)
            }
            await MainActor.run{
                callBack(soundData)
            }
        }
    }
    private static func loadAudioFileFromNetwork(url: URL) -> AVAudioFile? {
        var audioFile: AVAudioFile?
        let semaphore = DispatchSemaphore(value: 0)
        
        // Create custom URLSession with timeout configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Config.NETWORK_TIMEOUT_INTERVAL
        configuration.timeoutIntervalForResource = Config.NETWORK_TIMEOUT_INTERVAL
        let urlSession = URLSession(configuration: configuration)
        
        let task = urlSession.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                print("Error downloading audio file: \(error)")
                
                // Check if it's a timeout error and show toast
                if let urlError = error as? URLError, urlError.code == .timedOut {
                    DispatchQueue.main.async {
                        ToastUtil.showNetworkTimeoutError()
                    }
                }
                
                semaphore.signal()
                return
            }

            guard let tempURL = tempURL else {
                print("Failed to get temporary file URL")
                semaphore.signal()
                return
            }

            do {
                audioFile = try AVAudioFile(forReading: tempURL)
            } catch {
                print("Error reading audio file: \(error)")
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return audioFile
    }
    
    private static func generateData(audioFile:AVAudioFile)->[Float]{
        let stereo = audioFile.floatChannelData()!
        var processedSamples: [Float]
        if stereo[0].count >= COUNT {
            let chunkSize = stereo[0].count / COUNT
            processedSamples = Array(repeating: 0.0, count: COUNT)
            for i in 0..<COUNT {
                let startIndex = i * chunkSize
                let endIndex = min(startIndex + chunkSize, stereo[0].count)
                let chunk = stereo[0][startIndex..<endIndex]
                // 计算绝对值的总和
                let absSum = chunk.reduce(0.0) { $0 + abs($1) }
                let average = absSum / Float(chunk.count)
                processedSamples[i] = average
            }
        } else {
            processedSamples = Array(stereo[0])
        }
        // 映射 processedSamples 到 0...1
        if let minValue = processedSamples.min(), let maxValue = processedSamples.max() {
            let range = maxValue - minValue
            if range > 0 {
                processedSamples = processedSamples.map { (sample) -> Float in
                    return (sample - minValue) / range
                }
            } else {
                // 如果最大值和最小值相等，所有值设为 1
                processedSamples = Array(repeating: 1.0, count: processedSamples.count)
            }
        }
        return processedSamples
    }
    
    private static func getAudioDuration(from audioFile: AVAudioFile) -> TimeInterval? {
        // 获取采样点数
        let sampleCount = audioFile.length
        
        // 获取采样率
        let sampleRate = audioFile.processingFormat.sampleRate
        if sampleRate == 0{
            return 0
        }
        // 计算音频时长
        let duration = TimeInterval(sampleCount) / sampleRate
        
        return duration
    }
}

struct AudioInfo{
    var duration:Double = 0
    var data:[Float] =  Array(repeating: 0, count: AudioInfoUtil.COUNT)

}

