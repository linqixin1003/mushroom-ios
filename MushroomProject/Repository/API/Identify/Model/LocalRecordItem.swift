//
//  LocalRecordItem.swift
//  RockProject
//
//  Created by conalin on 2025/6/18.
//

import Foundation

enum LocalRecordType: String, Codable {
    case image
}

// 添加一个结构体来表示合并后的记录
struct LocalRecordItem: Identifiable, Codable {
    let id: String // 使用类型前缀+原始ID来确保唯一性
    let uid: String
    let type: LocalRecordType
    let createdAt: String
    let confidence: Float
    let latinName: String
    let commonName: String
    let mediaUrl: String // 统一存储图片或音频URL
    var identificationId: Int? = nil
    
    // 从图片识别记录创建
    static func fromImage(_ record: IdentificationRecord) -> LocalRecordItem {
        return LocalRecordItem(
            id: String(record.id), // 将Int转换为String
            uid: record.stoneId,
            type: .image,
            createdAt: record.createdAt,
            confidence: Float(record.confidence),
            latinName: record.source, // 使用source作为latinName的临时替代
            commonName: record.name,
            mediaUrl: record.imageUrl,
            identificationId: record.id
        )
    }
    
    
    // 从 SimpleMushroom 创建收藏项目
    static func fromSimpleMushroom(_ stone: SimpleMushroom) -> LocalRecordItem {
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = dateFormatter.string(from: Date())
        
        return LocalRecordItem(
            id: "collected_\(stone.id)",
            uid: stone.id,
            type: .image,
            createdAt: currentDate,
            confidence: 1.0, // 收藏项目设为最高置信度
            latinName: stone.name,
            commonName: stone.name,
            mediaUrl: stone.photoUrl ?? ""
        )
    }
}

// MARK: - 收藏状态检查扩展
extension LocalRecordItem {
    
    /// 检查指定的 uid 是否已经收藏
    /// - Parameters:
    ///   - uid: 要检查的鸟类 uid
    ///   - completion: 完成回调，返回 (isCollected: Bool, success: Bool)
    static func isCollected(uid: String, completion: @escaping (Bool, Bool) -> Void) {
        LocalRecordItemReadWrite.loadItems { items, success in
            guard success else {
                completion(false, false)
                return
            }
            let isCollected = items.contains { item in
                item.uid == uid && item.id.hasPrefix("collected_")
            }
            completion(isCollected, true)
        }
    }
    
    /// 切换收藏状态
    /// - Parameters:
    ///   - stone: 要收藏或取消收藏的石头
    ///   - completion: 完成回调，返回 (newCollectedState: Bool, success: Bool)
    static func toggleCollected(stone: SimpleMushroom, completion: @escaping (Bool, Bool) -> Void) {
        print("🔄 Toggle collection status - Stone ID: \(stone.id)")
        isCollected(uid: stone.id) { isCurrentlyCollected, success in
            guard success else {
                print("❌ Check collection status failed - ID: \(stone.id)")
                completion(false, false)
                return
            }
            
            print("📊 Current collection status - ID: \(stone.id), collected: \(isCurrentlyCollected)")
            
            if isCurrentlyCollected {
                // 取消收藏
                print("🗑️ Start removing from collection - ID: \(stone.id)")
                removeFromCollection(uid: stone.id, completion: completion)
            } else {
                // 添加收藏
                print("➕ Start adding to collection - ID: \(stone.id)")
                //saddToCollection(stone: stone, completion: completion)
            }
        }
    }
    
    /// 仅添加收藏（不检查当前状态，直接尝试添加）
    /// - Parameters:
    ///   - stone: 要收藏的石头
    ///   - completion: 完成回调，返回 success: Bool
    static func addToCollectionOnly(identificationId: Int, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let request = CollectionAddRequest(identificationId: identificationId)
                let response: CollectionAddResponse = try await ApiRequest.requestAsync(request: request)
                
                DispatchQueue.main.async {
                    if response.success {
                        print("✅ Added to collection successfully - identificationId: \(identificationId)")
                        completion(true)
                    } else {
                        print("❌ Add to collection failed: \(response.message)")
                        completion(false)
                    }
                }
            } catch {
                print("❌ Add to collection failed: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    /// 添加到收藏
    private static func addToCollection(identificationId: Int, completion: @escaping (Bool, Bool) -> Void) {
        Task {
            do {
                let request = CollectionAddRequest(identificationId: identificationId)
                let response: CollectionAddResponse = try await ApiRequest.requestAsync(request: request)
                
                DispatchQueue.main.async {
                    if response.success {
                        print("✅ Added to collection successfully - identificationId: \(identificationId)")
                        completion(true, true) // 新状态为已收藏
                    } else {
                        print("❌ Add to collection failed: \(response.message)")
                        completion(false, false)
                    }
                }
            } catch {
                print("❌ Add to collection failed: \(error)")
                DispatchQueue.main.async {
                    completion(false, false)
                }
            }
        }
    }
    
    /// 从收藏中移除
    private static func removeFromCollection(uid: String, completion: @escaping (Bool, Bool) -> Void) {
        Task {
            do {
                // 首先需要获取collectionId，这里假设uid就是collectionId
                // 如果需要其他逻辑来获取collectionId，需要根据实际情况调整
                guard let collectionId = Int(uid) else {
                    print("❌ Invalid collection ID: \(uid)")
                    DispatchQueue.main.async {
                        completion(true, false) // 保持当前状态，但操作失败
                    }
                    return
                }
                
                let request = DeleteCollectionRequest(collectionId: collectionId)
                let response: DeleteCollectionResponse = try await ApiRequest.requestAsync(request: request)
                
                DispatchQueue.main.async {
                    if response.success {
                        print("✅ Removed from collection successfully - ID: \(uid)")
                        completion(false, true) // 新状态为未收藏，操作成功
                    } else {
                        print("❌ Remove from collection failed: \(response.message)")
                        completion(true, false) // 保持当前状态，操作失败
                    }
                }
            } catch {
                print("❌ Remove from collection failed: \(error)")
                DispatchQueue.main.async {
                    completion(true, false) // 保持当前状态，操作失败
                }
            }
        }
    }
}
