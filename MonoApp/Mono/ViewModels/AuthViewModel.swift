import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var deviceCode: APIDeviceCode?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var pollingActive = false

    private var pollTask: Task<Void, Never>?

    func startAuth() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let code = try await APIService.shared.startDeviceAuth()
                deviceCode = code
                isLoading = false
                startPolling(sessionId: code.session_id)
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func startPolling(sessionId: String) {
        pollingActive = true
        pollTask = Task {
            while pollingActive && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s
                do {
                    let result = try await APIService.shared.pollToken(sessionId: sessionId)
                    if result.status == "authorized", let token = result.access_token {
                        Keychain.accessToken = token
                        pollingActive = false
                        isAuthenticated = true
                        return
                    }
                } catch {
                    // Keep polling unless cancelled
                }
            }
        }
    }

    func cancelPolling() {
        pollingActive = false
        pollTask?.cancel()
    }

    func logout() {
        Keychain.accessToken = nil
        isAuthenticated = false
        deviceCode = nil
    }
}
