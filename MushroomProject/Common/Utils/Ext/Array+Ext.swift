
extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        var result = [[Element]]()
        result.reserveCapacity(count / size + 1)
        for i in stride(from: 0, to: count, by: size) {
            let endIndex = Swift.min(i + size, count)
            result.append(Array(self[i..<endIndex]))
        }
        return result
    }
    
    func getOrNull(index: Int) -> Element? {
        if count == 0 || index < 0 || index > count - 1 {
            return nil
        }
        return self[index]
    }

    func isNotEmpty() -> Bool {
        return !isEmpty
    }
}

