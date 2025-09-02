import Foundation
import Alamofire
import UIKit

class ApiRequest {
    
    // MARK: - Session Configuration
    
    /// Custom session with timeout configuration
    private static let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Config.NETWORK_TIMEOUT_INTERVAL
        configuration.timeoutIntervalForResource = Config.NETWORK_TIMEOUT_INTERVAL
        return Session(configuration: configuration)
    }()
    
    // 默认公共请求头
    private static var commonHeaders: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    // 设置公共请求头
    static func setCommonHeaders(_ headers: [String: String]) {
        for (key, value) in headers {
            commonHeaders[key] = value
        }
    }
    
    // 添加单个公共请求头
    static func addCommonHeader(key: String, value: String) {
        commonHeaders[key] = value
    }
    
    // 移除公共请求头
    static func removeCommonHeader(key: String) {
        commonHeaders.remove(name: key)
    }
    
    // MARK: - Error Handling
    
    /// Process network error and return appropriate error message
    private static func processError(_ error: Error) -> Error {
        // Check if it's a timeout error
        if let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(let sessionError):
                if let urlError = sessionError as? URLError {
                    if urlError.code == .timedOut {
                        // Show timeout toast message on main thread
                        DispatchQueue.main.async {
                            ToastUtil.showNetworkTimeoutError()
                        }
                        let timeoutError = NSError(
                            domain: "NetworkTimeout",
                            code: -1001,
                            userInfo: [NSLocalizedDescriptionKey: "Network timeout, please try again!"]
                        )
                        return timeoutError
                    }
                }
            default:
                break
            }
        }
        
        // Check for URLError timeout directly
        if let urlError = error as? URLError, urlError.code == .timedOut {
            // Show timeout toast message on main thread
            DispatchQueue.main.async {
                ToastUtil.showNetworkTimeoutError()
            }
            let timeoutError = NSError(
                domain: "NetworkTimeout",
                code: -1001,
                userInfo: [NSLocalizedDescriptionKey: "Network timeout, please try again!"]
            )
            return timeoutError
        }
        
        return error
    }
    
    // GET 请求
    static func get<T: Decodable>(
        path: String,
        parameters: Parameters? = nil,
        additionalHeaders: HTTPHeaders? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(
            method: .get,
            path: path,
            parameters: parameters,
            additionalHeaders: additionalHeaders,
            completion: completion
        )
    }
    
    // GET 请求 - Async 版本
    static func getAsync<T: Decodable>(
        path: String,
        parameters: Parameters? = nil,
        additionalHeaders: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            get(
                path: path,
                parameters: parameters,
                additionalHeaders: additionalHeaders
            ) { (result: Result<T, Error>) in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // POST 请求
    static func post<T: Decodable>(
        path: String,
        parameters: Parameters? = nil,
        additionalHeaders: HTTPHeaders? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(
            method: .post,
            path: path,
            parameters: parameters,
            additionalHeaders: additionalHeaders,
            completion: completion
        )
    }
    
    // POST 请求 - Async 版本
    static func postAsync<T: Decodable>(
        path: String,
        parameters: Parameters? = nil,
        additionalHeaders: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            post(
                path: path,
                parameters: parameters,
                additionalHeaders: additionalHeaders
            ) { (result: Result<T, Error>) in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 通用请求方法
    private static func request<T: Decodable>(
        method: HTTPMethod,
        path: String,
        parameters: Parameters? = nil,
        additionalHeaders: HTTPHeaders? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // 构建完整的 URL
        let urlString = "\(Config.HOST)/\(path)"
        
        // 合并请求头
        var headers = commonHeaders
        
        // 确保device-token存在
        if PersistUtil.deviceId == nil {
            PersistUtil.deviceId = UDIDUtil.getUDID()
        }
        
        // 动态添加device-token和user-id
        headers["device-token"] = PersistUtil.deviceId ?? ""
        headers["user-id"] = PersistUtil.userId ?? ""
        
        if let additionalHeaders = additionalHeaders {
            for header in additionalHeaders {
                headers[header.name] = header.value
            }
        }
        
        // 打印请求信息
        debugPrint("[ApiRequest] 🌐 Request Info:")
        debugPrint("[ApiRequest] URL: \(urlString)")
        debugPrint("[ApiRequest] Method: \(method)")
        debugPrint("[ApiRequest] Headers: \(headers)")
        if let parameters = parameters {
            debugPrint("[ApiRequest] Parameters: \(parameters)")
        }
        
        // 根据请求方法选择不同的参数编码方式
        let encoding: ParameterEncoding = (method == .get || method == .delete) ? URLEncoding.default : JSONEncoding.default
        var mapPath = urlString
        if method == .delete {
            if let parameters = parameters {
                // 将 parameters 转换为键值都为 String 类型的字典
                let queryMap = parameters.mapValues { String(describing: $0) }
//                for value in queryMap.values {
//                    mapPath.append("/\(value)")
//                }
            }
        }
        
        
        // 发起请求
        session.request(
            mapPath,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        )
        .validate()
        .responseDecodable(of: T.self) { response in
            // 打印响应信息
            debugPrint("[ApiRequest] 📥 Response Info:")
            debugPrint("[ApiRequest] Status Code: \(response.response?.statusCode ?? 0)")
            
            // 先判断状态码是否为 204
            if let statusCode = response.response?.statusCode, statusCode == 204 {
                if T.self is String.Type || T.self is Optional<String>.Type {
                    let successValue = "success" as! T
                    debugPrint("[ApiRequest] ✅ Request successful, status code 204, returning success")
                    completion(.success(successValue))
                } else {
                    let error = NSError(domain: "ApiRequestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "204 response cannot be converted to \(T.self) type"])
                    debugPrint("[ApiRequest] ❌ Request failed: \(error)")
                    completion(.failure(error))
                }
                return
            }
            
            if let data = response.data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    debugPrint("[ApiRequest] Response Data: \(jsonString)")
                }
            }
            
            switch response.result {
            case .success(let value):
                debugPrint("[ApiRequest] ✅ Request successful")
                completion(.success(value))
            case .failure(let error):
                let processedError = processError(error)
                debugPrint("[ApiRequest] ❌ Request failed: \(processedError)")
                completion(.failure(processedError))
            }
        }
    }
    
    // 通用请求方法 - Async 版本
    private static func requestAsync<T: Decodable>(
        method: HTTPMethod,
        path: String,
        parameters: Parameters? = nil,
        additionalHeaders: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            request(
                method: method,
                path: path,
                parameters: parameters,
                additionalHeaders: additionalHeaders
            ) { (result: Result<T, Error>) in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 使用RequestProtocol的请求方法 - Async版本
    static func requestAsync<T: Decodable, R: RequestProtocol>(
        request: R
    ) async throws -> T {
        // 构建请求参数
        let method = request.method
        let path = request.path
        let parameters = request.parameters
        
        // 处理认证头
        var additionalHeaders: HTTPHeaders?
        if request.needAuth, let token = PersistUtil.accessToken {
            additionalHeaders = ["Authorization": "Bearer \(token)"]
        }
        
        // 检查是否有multipartFormData
        if let multipartFormData = request.multipartFormData {
            // 如果有multipartFormData，使用上传方法
            return try await uploadAsync(
                path: path,
                multipartFormData: multipartFormData,
                additionalHeaders: additionalHeaders
            )
        } else {
            // 如果没有multipartFormData，使用普通请求方法
            return try await requestAsync(
                method: method,
                path: path,
                parameters: parameters,
                additionalHeaders: additionalHeaders
            )
        }
    }
    
    // 上传文件
    static func upload<T: Decodable>(
        path: String,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        additionalHeaders: HTTPHeaders? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // 构建完整的 URL
        let urlString = "\(Config.HOST)/\(path)"
        
        // 合并请求头
        var headers = commonHeaders
        
        // 确保device-token存在
        if PersistUtil.deviceId == nil {
            PersistUtil.deviceId = UDIDUtil.getUDID()
        }
        
        // 动态添加device-token和user-id
        headers["device-token"] = PersistUtil.deviceId ?? ""
        headers["user-id"] = PersistUtil.userId ?? ""
        
        if let additionalHeaders = additionalHeaders {
            for header in additionalHeaders {
                headers[header.name] = header.value
            }
        }
        
        // 上传文件
        session.upload(
            multipartFormData: multipartFormData,
            to: urlString,
            headers: headers
        )
        .validate()
        .responseDecodable(of: T.self) { response in
            debugPrint("[ApiRequest] request: \(response.request as Any)")
            if let data = response.data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    debugPrint("[ApiRequest] Response Data: \(jsonString)")
                }
            }
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                let processedError = processError(error)
                completion(.failure(processedError))
            }
        }
    }
    
    // 上传文件 - Async 版本
    static func uploadAsync<T: Decodable>(
        path: String,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        additionalHeaders: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            upload(
                path: path,
                multipartFormData: multipartFormData,
                additionalHeaders: additionalHeaders
            ) { (result: Result<T, Error>) in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 下载文件
    static func download(
        path: String,
        destination: DownloadRequest.Destination? = nil,
        additionalHeaders: HTTPHeaders? = nil,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        // 构建完整的 URL
        let urlString = "\(Config.HOST)/\(path)"
        
        // 合并请求头
        var headers = commonHeaders
        
        // 确保device-token存在
        if PersistUtil.deviceId == nil {
            PersistUtil.deviceId = UDIDUtil.getUDID()
        }
        
        // 动态添加device-token和user-id
        headers["device-token"] = PersistUtil.deviceId ?? ""
        headers["user-id"] = PersistUtil.userId ?? ""
        
        if let additionalHeaders = additionalHeaders {
            for header in additionalHeaders {
                headers[header.name] = header.value
            }
        }
        
        // 下载文件
        session.download(
            urlString,
            headers: headers,
            to: destination
        )
        .validate()
        .responseURL { response in
            switch response.result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                let processedError = processError(error)
                completion(.failure(processedError))
            }
        }
    }
    
    // 下载文件 - Async 版本
    static func downloadAsync(
        path: String,
        destination: DownloadRequest.Destination? = nil,
        additionalHeaders: HTTPHeaders? = nil
    ) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            download(
                path: path,
                destination: destination,
                additionalHeaders: additionalHeaders
            ) { result in
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
