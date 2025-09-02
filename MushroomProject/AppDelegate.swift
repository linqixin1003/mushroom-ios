
import FirebaseCore
import UIKit
import AVFoundation
import AudioKit
import Firebase
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FireBaseEvent.configPublicParam()
        initRecorder()
        ViewImageUtil.initNetWork()
        
        // 初始化购买管理器
        let _ = LocalPurchaseManager.shared
        
        self.configWindow()
        
        // Override point for customization after application launch.
        
        #if DEBUG
        // 添加本地化测试 (仅在DEBUG模式下)
        print("=== AppDelegate Localization Debug ===")
        print("System preferred languages: \(Locale.preferredLanguages)")
        print("Current locale: \(Locale.current)")
        print("LocalizationManager current language: \(LocalizationManager.shared.currentLanguage.rawValue)")
        
        // 测试本地化
        Language.testLocalization()
        
        // 检查Bundle中的本地化文件
        print("Available localizations in main bundle: \(Bundle.main.localizations)")
        print("Preferred localizations: \(Bundle.main.preferredLocalizations)")
        
        // 测试特定key的本地化
        let testKeys = ["home_action_identify", "home_action_record", "home_vip_banner_text", "home_your_daily_stone", "home_stones_near_you"]
        for key in testKeys {
            let localized = LocalizationManager.shared.localizedString(for: key)
            print("Key '\(key)' -> '\(localized)'")
        }
        #endif
        
        return true
    }
    
    private func initRecorder() {
        do {
            Settings.bufferLength = .short
            Settings.sampleRate = 16_000
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            print(err)
        }
    }

    private func configWindow() {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .themeBG
        let placeholder = SplashViewController()
        let nav = BaseNavigationViewController(rootViewController: placeholder)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        self.window?.overrideUserInterfaceStyle = .light
    }
    
    func restartApp() {
        self.configWindow()
    }
}

