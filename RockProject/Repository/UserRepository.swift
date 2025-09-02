import Alamofire
import Foundation

class UserRepository {
    
    public static func initDeviceAsync() async -> Bool {
        if PersistUtil.deviceId == nil {
            PersistUtil.deviceId = UDIDUtil.getUDID()
        }
        let req = DeviceAuthRequest()
        let result: DeviceAuthResponse? = try? await ApiRequest.requestAsync(request: req)
        guard let result else {
            return false
        }
        PersistUtil.user = result.user
        PersistUtil.accessToken = result.accessToken
        return true
    }
    
    public static func loginAsync() async -> Bool {
        if PersistUtil.deviceId == nil {
            PersistUtil.deviceId = UDIDUtil.getUDID()
        }
        let req = LoginRequest()
        let result: LoginResponse? = try? await ApiRequest.requestAsync(request: req)
        guard let result else {
            return false
        }
        PersistUtil.userId = result.userId
        return true
    }
}
