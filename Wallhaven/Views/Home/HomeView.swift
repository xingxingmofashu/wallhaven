import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var selectedWallpaper: Wallpaper?

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadState {
                case .idle, .loading:
                    LoadingView()

                case .loaded:
                    GridView(
                        wallpapers: viewModel.wallpapers,
                        isLoadingMore: viewModel.isLoadingMore,
                        onLoadMore: { viewModel.loadMore() },
                        onSelect: { selectedWallpaper = $0 },
                        scrollAnchor: viewModel.scrollAnchor
                    )

                case .failed(let error):
                    ErrorView(
                        message: (error as? LocalizedError)?.errorDescription ?? "Unknown error",
                        retryAction: { Task { await viewModel.refresh() } }
                    )
                }
            }
           .navigationTitle("Home")
           .navigationBarTitleDisplayMode(.inline)
           .task { viewModel.loadInitial() }
            .refreshable { await viewModel.refresh() }
            .navigationDestination(item: $selectedWallpaper) { wallpaper in
                if let index = viewModel.wallpapers.firstIndex(where: { $0.id == wallpaper.id }),
                   viewModel.wallpapers.indices.contains(index)
                {
                    DetailView(
                        wallpapers: viewModel.wallpapers,
                        startIndex: index
                    )
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
