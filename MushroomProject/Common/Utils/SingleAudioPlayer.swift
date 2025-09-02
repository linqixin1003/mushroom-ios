import AVFoundation

class SingleAudioPlayer {
    static let shared = SingleAudioPlayer()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    var replaceCallBack: (() -> Void)?
    private var playToEndObserver: NSObjectProtocol?
    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }

    func isPlayerPlaying(_ player: AVPlayer) -> Bool {
        return player.rate != 0 && player.error == nil
    }

    func playSound(url: String, callback: @escaping (Int, Int, Bool) -> Void, replaceCallBack: @escaping ()->Void) {
        
        guard let audioURL = URL(string: url) else {
            print("Invalid audio URL")
            return
        }
        if let player = self.player{
            if isPlayerPlaying(player) {
                stopSound()
            }
        }
        self.replaceCallBack = replaceCallBack
        playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)

        // 监听播放完成事件
        playToEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let duration = Int(self.playerItem?.duration.seconds ?? 0) * 1000
            callback(duration, duration, true)
        }

        // 监听播放进度
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentPosition = Int(CMTimeGetSeconds(time) * 1000)
            var duration:Int = 0
            if let tempDuration = self.playerItem?.duration.seconds{
                if tempDuration.isFinite && !tempDuration.isNaN {
                    duration = Int(tempDuration * 1000)
                } else {
                    duration = 0
                }
            }
            callback(currentPosition,duration, false)
        }

        player?.play()
    }

    func stopSound() {
        if let replaceCallBack = self.replaceCallBack{
            replaceCallBack()
        }
        player?.pause()
        playerItem = nil
        player = nil
        replaceCallBack = nil
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

