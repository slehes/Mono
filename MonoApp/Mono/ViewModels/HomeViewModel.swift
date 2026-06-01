import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var landing = MonoLanding()
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        guard landing.chart.isEmpty else { return }
        isLoading = true
        do {
            landing = try await APIService.shared.getLanding()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        isLoading = true
        do {
            landing = try await APIService.shared.getLanding()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
