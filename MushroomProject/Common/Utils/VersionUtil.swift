import Foundation
class VersionHelper {
    static func getAppVersionName() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
}
