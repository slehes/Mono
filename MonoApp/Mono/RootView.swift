import SwiftUI

struct RootView: View {
    @State private var isAuthenticated = Keychain.accessToken != nil
    @State private var selectedTab = 0
    @State private var showFullPlayer = false
    @State private var showAuth = false
    @ObservedObject private var player = PlayerService.shared

    var body: some View {
        ZStack {
            mainContent
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showFullPlayer) {
            FullScreenPlayer(isPresented: $showFullPlayer)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showAuth) {
            AuthScreen(isAuthenticated: $isAuthenticated)
        }
        .onChange(of: isAuthenticated) { newValue in
            if newValue {
                showAuth = false
            }
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0: HomeScreen(showAuth: $showAuth, isAuthenticated: $isAuthenticated)
                case 1: SearchScreen()
                case 2: LibraryScreen(showAuth: $showAuth, isAuthenticated: $isAuthenticated)
                default: HomeScreen(showAuth: $showAuth, isAuthenticated: $isAuthenticated)
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
