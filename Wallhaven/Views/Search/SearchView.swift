import SwiftUI

struct SearchView: View {
    @State private var viewModel        = SearchViewModel()
    @State private var selectedWallpaper: Wallpaper?
    @State private var showFilter       = false
    @Environment(NavigationState.self) private var navigationState

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadState {
                case .idle:
                    idleView

                case .loading:
                    LoadingView("Searching...")

                case .loaded:
                    if viewModel.wallpapers.isEmpty {
                        NoResultsView()
                    } else {
                        resultsView
                    }

                case .failed(let error):
                    ErrorView(message: (error as? LocalizedError)?.errorDescription ?? "Unknown error") {
                        viewModel.search()
                    }
                }
            }
           .navigationTitle("Search")
           .navigationBarTitleDisplayMode(.inline)
           .searchable(
                text: $viewModel.filters.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search wallpapers, tags..."
            )
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .task(id: navigationState.shouldSearch) {
                guard navigationState.shouldSearch else { return }
                viewModel.filters.query = navigationState.searchQuery
                navigationState.shouldSearch = false
                viewModel.search()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showFilter) {
                FilterSheetView(filters: $viewModel.filters) {
                    viewModel.search()
                }
            }
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

    // MARK: - Idle

    private var idleView: some View {
        ContentUnavailableView(
            "Search Wallpapers",
            systemImage: "magnifyingglass",
            description: Text("Enter keywords to search, or tap the filter button to set conditions")
        )
    }

    // MARK: - Results

    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Result count
            Text(localizedResultCount)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 4)

            GridView(
                wallpapers: viewModel.wallpapers,
                isLoadingMore: viewModel.isLoadingMore,
                onLoadMore: { viewModel.loadMore() },
                onSelect: { selectedWallpaper = $0 }
            )
        }
    }

    private var localizedResultCount: String {
        String(
            format: NSLocalizedString("search.results.count", comment: ""),
            viewModel.totalResults
        )
    }
}

#Preview {
    SearchView()
}
