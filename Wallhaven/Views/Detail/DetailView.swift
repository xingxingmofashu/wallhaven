import SwiftUI
import SwiftData

struct DetailView: View {
    @State private var viewModel: DetailViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationState.self) private var navigationState
    @Query(sort: \CollectionFolder.sortOrder)
    private var collections: [CollectionFolder]
    @State private var showShareSheet = false
    @State private var showInfoSheet = false
    @State private var showFullscreen = false
    @State private var scrollPosition: Int?
    @State private var wallpapers: [Wallpaper]
    @State private var selectedIndex: Int

    private var currentID: String? { wallpapers.indices.contains(selectedIndex) ? wallpapers[selectedIndex].id : nil }

    init(wallpaper: Wallpaper, relatedWallpapers: [Wallpaper] = []) {
        _viewModel = State(initialValue: DetailViewModel(wallpaper: wallpaper, relatedWallpapers: relatedWallpapers))
        _wallpapers = State(initialValue: [wallpaper])
        _selectedIndex = State(initialValue: 0)
        _scrollPosition = State(initialValue: 0)
    }

    init(wallpapers: [Wallpaper], startIndex: Int) {
        let wallpaper = wallpapers[startIndex]
        _viewModel = State(initialValue: DetailViewModel(wallpaper: wallpaper, relatedWallpapers: wallpapers))
        _wallpapers = State(initialValue: wallpapers)
        _selectedIndex = State(initialValue: startIndex)
        _scrollPosition = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack {
            (showFullscreen ? Color.black : Color(.systemBackground)).ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(Array(wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                            imageView(for: wallpaper)
                                .containerRelativeFrame(.horizontal)
                                .clipped()
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrollPosition)
                .simultaneousGesture(TapGesture().onEnded { showFullscreen.toggle() })

                DetailThumbnailView(
                    relatedWallpapers: viewModel.relatedWallpapers,
                    currentID: currentID,
                    favoritedIDs: viewModel.favoritedIDs,
                    selectedIndex: selectedIndex,
                    onSelect: { wallpaper in
                        if let idx = wallpapers.firstIndex(where: { $0.id == wallpaper.id }) {
                            scrollPosition = idx
                        } else {
                            wallpapers = [wallpaper]
                            scrollPosition = 0
                            viewModel.selectRelated(wallpaper)
                        }
                    }
                )
                    .frame(height: 44)
                    .opacity(showFullscreen ? 0 : (viewModel.relatedWallpapers.isEmpty ? 0 : 1))
            }

        }
        .animation(.easeInOut(duration: 0.25), value: showFullscreen)
        .statusBar(hidden: showFullscreen)
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    guard !showFullscreen else { return }
                    let vertical = value.translation.height
                    let horizontal = value.translation.width
                    if vertical > 80 && abs(horizontal) < abs(vertical) {
                        dismiss()
                    }
                }
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            if !showFullscreen {
               DetailTopToolbar(
                   onDismiss: { dismiss() },
                   wallpaperURL: viewModel.wallpaper.url,
                   onFindSimilar: {
                       dismiss()
                       navigationState.searchTag("like:\(viewModel.wallpaper.id)")
                   }
               )
                DetailBottomToolbar(
                    isFavorited: viewModel.isFavorited,
                    isInCollection: viewModel.isInCollection,
                    isDownloading: viewModel.isDownloading,
                    onShare: { showShareSheet = true },
                    onToggleFavorite: { viewModel.toggleFavorite(in: modelContext) },
                    onInfo: { showInfoSheet = true },
                    onAddToCollection: { viewModel.handleAddToCollection(in: modelContext, collections: collections) },
                    onSaveToPhotos: { viewModel.saveToPhotos() }
                )
            }
        }
        .onChange(of: scrollPosition) { _, newValue in
            guard let index = newValue, wallpapers.indices.contains(index), index != selectedIndex else { return }
            selectedIndex = index
            viewModel.selectRelated(wallpapers[index])
            preloadAdjacent(at: index)
            cancelDistantDownloads(currentIndex: index)
        }
        .task {
            viewModel.refreshFavoriteStatus(in: modelContext)
            viewModel.loadDetailIfNeeded()
            viewModel.loadRelatedWallpapers()
            preloadAdjacent(at: selectedIndex)
        }
        .onDisappear {
            CacheImage.shared.cancelAllDownloads()
        }
        .onChange(of: viewModel.saveResult) { _, result in
            guard let result else { return }
            if result == .success {
                hapticFeedback()
            } else {
                notificationFeedback(.error)
            }
            viewModel.saveResult = nil
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: viewModel.shareItems)
        }
        .sheet(isPresented: $showInfoSheet) {
            DetailInfoSheetView(
                wallpaper: viewModel.wallpaper,
                formattedInfo: viewModel.formattedInfo,
                tags: viewModel.wallpaper.tags ?? [],
                onSearchTag: { tag in
                    dismiss()
                    navigationState.searchTag(tag)
                },
                onDone: { showInfoSheet = false }
            )
        }
        .sheet(isPresented: $viewModel.showCollectionPicker) {
            CollectionPickerSheet(
                collections: collections,
                onSelect: { collectionID in
                    viewModel.addToSpecificCollection(collectionID, in: modelContext)
                },
                onCreateNew: { name in
                    let newCollection = CollectionFolder(name: name)
                    modelContext.insert(newCollection)
                    modelContext.saveWithLog()
                    viewModel.addToSpecificCollection(newCollection.id, in: modelContext)
                }
            )
        }
    }

    // MARK: - Image View

    private func preloadAdjacent(at index: Int) {
        for offset in [-1, 1] {
            let target = index + offset
            if wallpapers.indices.contains(target), let url = wallpapers[target].fullURL {
                CacheImage.shared.preload(url: url)
            }
        }
    }

    /// Cancel in-flight full-res downloads for pages that are no longer
    /// adjacent to the current page — prevents wasted bandwidth when
    /// swiping quickly through the paging ScrollView.
    private func cancelDistantDownloads(currentIndex: Int) {
        for (i, wallpaper) in wallpapers.enumerated() {
            guard let url = wallpaper.fullURL else { continue }
            if abs(i - currentIndex) > 1 {
                CacheImage.shared.cancelDownload(for: url)
            }
        }
    }

    private func imageView(for wallpaper: Wallpaper) -> some View {
        CacheAsyncImage(url: wallpaper.fullURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            placeholderView(for: wallpaper)
        }
    }

    private func placeholderView(for wallpaper: Wallpaper) -> some View {
        CacheAsyncImage(url: wallpaper.thumbnailURL) { thumb in
            thumb
                .resizable()
                .scaledToFill()
                .blur(radius: 20, opaque: true)
        } placeholder: {
            Rectangle()
                .fill(Color(.systemGray5))
        }
        .aspectRatio(wallpaper.aspectRatio, contentMode: .fit)
        .clipShape(Rectangle())
    }

}
