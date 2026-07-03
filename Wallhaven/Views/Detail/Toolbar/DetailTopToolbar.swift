import SwiftUI

struct DetailTopToolbar: ToolbarContent {
    let onDismiss: () -> Void
    let wallpaperURL: String
    let onFindSimilar: () -> Void

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Open in Browser", systemImage: "safari") {
                    if let url = URL(string: wallpaperURL) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Copy Link", systemImage: "doc.on.doc") {
                    UIPasteboard.general.string = wallpaperURL
                }
                Button("detail.find_similar", systemImage: "sparkle.magnifyingglass") {
                    onFindSimilar()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundStyle(.primary)
            }
        }
    }
}
