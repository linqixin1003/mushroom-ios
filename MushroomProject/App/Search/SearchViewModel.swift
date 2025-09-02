import Combine

class SearchViewModel: ObservableObject {
    @Published var searchResults: [SimpleStone] = []
    private var searchTask: Task<Void, Never>?
    var isLoading = false
    func search(query: String) {
        if query.count < 2 {
            return
        }
        searchTask?.cancel()
        
        searchTask = Task {
            guard !query.isEmpty else {
                await MainActor.run {
                    self.searchResults = []
                }
                return
            }
            isLoading = true
            let result = await ItemRepository.searchAsync(query: query)
            isLoading = false
            await MainActor.run {
                self.searchResults = result?.stones ?? []
            }
        }
    }
}
