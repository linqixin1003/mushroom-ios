import Foundation

class LocalRecordItemReadWrite {
    private static let cache = CodableCache<[LocalRecordItem]>(cacheName: "LocalRecordItems")
    private static let key = "local_record_items"
    
    // 1. 保存LocalRecordItem列表
    static func saveItems(_ items: [LocalRecordItem], completion: ((Bool) -> Void)? = nil) {
        cache.save(items, forKey: key) {
            // CodableCache 的 save 回调没有参数，所以只能认为成功
            completion?(true)
        }
    }
    
    // 2. 读取LocalRecordItem列表
    static func loadItems(completion: @escaping ([LocalRecordItem], Bool) -> Void) {
        cache.load(forKey: key) { items in
            if let items = items {
                completion(items, true)
            } else {
                // 缓存为空是正常情况（特别是首次使用），返回空数组但success=true
                completion([], true)
            }
        }
    }
    
    // 3. 插入一个LocalRecordItem
    static func insertItem(_ item: LocalRecordItem, completion: ((Bool) -> Void)? = nil) {
        loadItems { items, success in
            guard success else {
                completion?(false)
                return
            }
            var updatedItems = items
            updatedItems.insert(item, at: 0)
            saveItems(updatedItems, completion: completion)
        }
    }
    
    // 4. 清空所有LocalRecordItem
    static func clearAllItems(completion: ((Bool) -> Void)? = nil) {
        cache.remove(forKey: key) {
            completion?(true)
        }
    }

    static func deleteItem(_ item: LocalRecordItem, completion: ((Bool) -> Void)? = nil) {
        loadItems { items, success in
            guard success else {
                completion?(false)
                return
            }
            
            // 通过id删除指定项目
            let filteredItems = items.filter { $0.id != item.id }
            saveItems(filteredItems, completion: completion)
        }
    }
}
