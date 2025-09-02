import FirebaseAnalytics

class FireBaseEvent{
    
    static func configPublicParam(){
        Analytics.setDefaultEventParameters([
            "userId": PersistUtil.userId ?? "",
            "deviceType": "1"
        ])
    }
    
    static func send(eventName: String, params: [String: String]? = nil) {
        // 调用 FirebaseAnalytics 的 logEvent 方法记录事件
        Analytics.logEvent(eventName, parameters: params)
        print("send event: \(eventName), params: \(params)")
    }
}
