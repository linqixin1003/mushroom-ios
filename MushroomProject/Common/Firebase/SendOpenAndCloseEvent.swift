class SendOpenAndCloseEvent {
    let openEventName:String
    let closeEventName:String
    var params:[String:String]? = nil
    init(openEventName: String, closeEventName:String, params: [String: String]? = nil){
        self.openEventName = openEventName
        self.closeEventName = closeEventName
        self.params = params
        FireBaseEvent.send(eventName: openEventName, params: params)
    }
    
    deinit{
        FireBaseEvent.send(eventName: closeEventName, params: params)
    }
}

