import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    static var longitude = -119.88467
    static var latitude = 47.25015
    func locate(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 请求前台定位权限
        locationManager.startUpdatingLocation() // 开始定位
    }
    
    // 获取定位信息的回调
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //print("经度: \(location.coordinate.longitude), 纬度: \(location.coordinate.latitude)")
            LocationManager.longitude = location.coordinate.longitude
            LocationManager.latitude = location.coordinate.latitude
        }
    }
    
    // 处理定位失败
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location failed: \(error.localizedDescription)")
    }
}


// 手动设置 VIP 状态
func debugSetVipStatus(_ status: Bool) {
    // Implementation for debugSetVipStatus
}

// 清除所有购买记录
func debugClearPurchases() {
    // Implementation for debugClearPurchases
}

// 显示环境信息
func debugShowEnvironmentInfo() {
    // Implementation for debugShowEnvironmentInfo
}

// 重新加载产品
func debugReloadProducts() {
    // Implementation for debugReloadProducts
}

