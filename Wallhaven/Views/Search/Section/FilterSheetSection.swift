 import SwiftUI
 
 struct FilterSheetSection: View {
     @Binding var filters: SearchFilters
 
     private var hasAPIKey: Bool { SettingsViewModel.shared.hasApiKey }
 
     var body: some View {
         Section("Categories") {
             Toggle("General", isOn: $filters.general)
             Toggle("Anime",   isOn: $filters.anime)
             Toggle("People",  isOn: $filters.people)
         }
 
         Section("Purity") {
             Toggle("SFW (Safe)",   isOn: $filters.sfw)
             Toggle("Sketchy",      isOn: $filters.sketchy)
             Toggle("NSFW (Adult)", isOn: $filters.nsfw)
                 .foregroundStyle(filters.nsfw ? .red : .primary)
                 .disabled(!hasAPIKey)
             if !hasAPIKey {
                 Text("search.nsfw.apikey_required")
                     .font(.caption)
                     .foregroundStyle(.secondary)
             }
         }
 
         Section {
             DisclosureGroup("search.tips") {
                 VStack(alignment: .leading, spacing: 8) {
                     syntaxRow("tagname",     "search.tips.fuzzy")
                     syntaxRow("-tag",        "search.tips.exclude")
                     syntaxRow("+tag",        "search.tips.include")
                     syntaxRow("@username",   "search.tips.user")
                     syntaxRow("id:123",      "search.tips.exact")
                     syntaxRow("type:png",    "search.tips.type")
                     syntaxRow("like:94x38z", "search.tips.similar")
                 }
                 .padding(.vertical, 4)
             }
         }
 
         Section("Sorting") {
             Picker("Sort by", selection: $filters.sorting) {
                 ForEach(SearchFilters.Sorting.allCases) { sorting in
                     Text(sorting.displayName).tag(sorting)
                 }
             }
             Picker("Order", selection: $filters.order) {
                 ForEach(SearchFilters.Order.allCases) { order in
                     Text(order.displayName).tag(order)
                 }
             }
         }
 
         if filters.sorting == .topList {
             Section("Toplist Time Range") {
                 Picker("Range", selection: $filters.topRange) {
                     ForEach(SearchFilters.TopRange.allCases) { range in
                         Text(range.displayName).tag(range)
                     }
                 }
                 .pickerStyle(.segmented)
             }
         }
 
         Section("Resolution") {
             TextField("Min resolution, e.g. 1920x1080", text: $filters.atLeast)
                 .keyboardType(.numbersAndPunctuation)
                 .autocorrectionDisabled()
         }
 
         Section("Ratio") {
             Picker("Common Ratios", selection: $filters.ratios) {
                 Text("Any").tag("")
                 Text("16:9").tag("16x9")
                 Text("16:10").tag("16x10")
                 Text("4:3").tag("4x3")
                 Text("9:16 (Portrait)").tag("9x16")
                 Text("1:1 (Square)").tag("1x1")
             }
         }
 
         Section("Dominant Color") {
             ScrollView(.horizontal, showsIndicators: false) {
                 HStack(spacing: 10) {
                     Circle()
                         .strokeBorder(.secondary, lineWidth: 2)
                         .frame(width: 36, height: 36)
                         .overlay {
                             if filters.selectedColor.isEmpty {
                                 Image(systemName: "checkmark")
                                     .font(.caption.bold())
                                     .foregroundStyle(.secondary)
                             }
                         }
                         .onTapGesture { filters.selectedColor = "" }
                     ForEach(WallhavenColor.all) { color in
                         colorCircle(color)
                     }
                 }
                 .padding(.vertical, 4)
             }
         }
     }
 
     private func colorCircle(_ color: WallhavenColor) -> some View {
         let isSelected = filters.selectedColor == color.hex
         return Circle()
             .fill(Color(hex: color.hex))
             .frame(width: 36, height: 36)
             .overlay {
                 Circle()
                     .strokeBorder(isSelected ? .white : .clear, lineWidth: 3)
                 Circle()
                     .strokeBorder(isSelected ? Color(hex: color.hex) : .clear, lineWidth: 5)
                     .scaleEffect(1.25)
                 if isSelected {
                     Image(systemName: "checkmark")
                         .font(.caption2.bold())
                         .foregroundStyle(.white)
                 }
             }
             .onTapGesture {
                 filters.selectedColor = isSelected ? "" : color.hex
             }
     }
 
     private func syntaxRow(_ syntax: String, _ descriptionKey: LocalizedStringKey) -> some View {
         HStack(spacing: 8) {
             Text(syntax)
                 .font(.system(.body, design: .monospaced))
                 .foregroundStyle(.secondary)
             Text(descriptionKey)
                 .font(.caption)
                 .foregroundStyle(.secondary)
         }
     }
 }
