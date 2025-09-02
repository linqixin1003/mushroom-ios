import Foundation

final class CodableCache<T: Codable> {
    
    private let fileManager = FileManager.default
    private let diskQueue = DispatchQueue(label: "codable.cache.disk.queue", attributes: .concurrent)
    private let memoryCache = NSCache<NSString, NSData>()
    
    private let directoryURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(cacheName: String) {
        let baseURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.directoryURL = baseURL.appendingPathComponent("CodableCache/\(cacheName)", isDirectory: true)
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
    
    private func fileURL(forKey key: String) -> URL {
        directoryURL.appendingPathComponent(key).appendingPathExtension("json")
    }
    
    func save(_ object: T, forKey key: String, completion: (() -> Void)? = nil) {
        do {
            let data = try encoder.encode(object)
            memoryCache.setObject(data as NSData, forKey: key as NSString)
            diskQueue.async(flags: .barrier) {
                let url = self.fileURL(forKey: key)
                try? data.write(to: url, options: .atomic)
                DispatchQueue.main.async {
                    completion?()
                }
            }
        } catch {
            print("❌ Save error: \(error)")
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func save(_ object: T, forKey key: String) async {
        await withCheckedContinuation { continuation in
            save(object, forKey: key) {
                continuation.resume()
            }
        }
    }
    
    func load(forKey key: String, completion: @escaping (T?) -> Void) {
        if let cachedData = memoryCache.object(forKey: key as NSString) {
            let object = try? decoder.decode(T.self, from: cachedData as Data)
            return completion(object)
        }
        
        diskQueue.async {
            let url = self.fileURL(forKey: key)
            guard let data = try? Data(contentsOf: url),
                  let object = try? self.decoder.decode(T.self, from: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            self.memoryCache.setObject(data as NSData, forKey: key as NSString)
            DispatchQueue.main.async {
                completion(object)
            }
        }
    }
    
    func load(forKey key: String) async -> T? {
        await withCheckedContinuation { continuation in
            load(forKey: key) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func remove(forKey key: String, completion: (() -> Void)? = nil) {
        memoryCache.removeObject(forKey: key as NSString)
        diskQueue.async(flags: .barrier) {
            let url = self.fileURL(forKey: key)
            try? self.fileManager.removeItem(at: url)
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func remove(forKey key: String) async {
        await withCheckedContinuation { continuation in
            remove(forKey: key) {
                continuation.resume()
            }
        }
    }
    
    func removeAll(completion: (() -> Void)? = nil) {
        memoryCache.removeAllObjects()
        diskQueue.async(flags: .barrier) {
            try? self.fileManager.removeItem(at: self.directoryURL)
            try? self.fileManager.createDirectory(at: self.directoryURL, withIntermediateDirectories: true)
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func removeAll() async {
        await withCheckedContinuation { continuation in
            removeAll {
                continuation.resume()
            }
        }
    }
}
