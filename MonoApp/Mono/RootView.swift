import SwiftUI

struct RootView: View {
    @State private var isAuthenticated = Keychain.accessToken != nil
    @State private var selectedTab = 0
    @State private var showFullPlayer = false
    @ObservedObject private var player = PlayerService.shared

    var body: some View {
        ZStack {
            if isAuthenticated {
                mainContent
            } else {
                AuthScreen(isAuthenticated: $isAuthenticated)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showFullPlayer) {
            FullScreenPlayer(isPresented: $showFullPlayer)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0: HomeScreen()
                case 1: SearchScreen()
                case 2: LibraryScreen()
                default: HomeScreen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom glass bar
            VStack(spacing: 8) {
                // Mini player
                if player.currentTrack != nil {
                    MiniPlayer(showFullPlayer: $showFullPlayer)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.4), value: player.currentTrack != nil)
                }

                // Glass tab bar
                GlassTabBar(
                    selection: $selectedTab,
                    items: [
                        (icon: "house", label: "Главная"),
                        (icon: "magnifyingglass", label: "Поиск"),
                        (icon: "music.note.list", label: "Коллекция"),
                    ]
                )
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard)
    }
}
