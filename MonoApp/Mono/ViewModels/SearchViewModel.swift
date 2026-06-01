import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var result = MonoSearchResult()
    @Published var isSearching = false
    @Published var error: String?

    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    init() {
        $query
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] q in
                if q.trimmingCharacters(in: .whitespaces).isEmpty {
                    self?.result = MonoSearchResult()
                } else {
                    self?.performSearch(q)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(_ q: String) {
        searchTask?.cancel()
        isSearching = true
        searchTask = Task {
            do {
                let res = try await APIService.shared.search(q)
                guard !Task.isCancelled else { return }
                result = res
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error.localizedDescription
            }
            isSearching = false
        }
    }
}
