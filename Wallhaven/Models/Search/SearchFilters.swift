import Foundation

// MARK: - Search Filters

/// Search filter criteria, bound to SearchViewModel
struct SearchFilters: Equatable {

    var query: String = ""

    // categories: each bit corresponds to general / anime / people, 1=on 0=off
    var general: Bool = true
    var anime: Bool   = true
    var people: Bool  = true

    // purity: each bit corresponds to sfw / sketchy / nsfw
    var sfw: Bool     = true
    var sketchy: Bool = false
    var nsfw: Bool    = false

    var sorting: Sorting     = .dateAdded
    var order: Order         = .desc
    var topRange: TopRange   = .oneMonth

    var atLeast: String      = ""     // e.g. "1920x1080"
    var resolutions: String  = ""     // comma-separated e.g. "1920x1080,2560x1440"
    var ratios: String       = ""     // comma-separated e.g. "16x9,16x10"
    var selectedColor: String  = ""     // single color hex e.g. "ff0000"
    var seed: String?                  // seed for random sorting

    // MARK: - Enums

    enum Sorting: String, CaseIterable, Identifiable {
        case dateAdded  = "date_added"
        case relevance  = "relevance"
        case random     = "random"
        case views      = "views"
        case favorites  = "favorites"
        case topList    = "toplist"
        case hot        = "hot"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .dateAdded:  return NSLocalizedString("sorting.latest", comment: "")
            case .relevance:  return NSLocalizedString("sorting.relevance", comment: "")
            case .random:     return NSLocalizedString("sorting.random", comment: "")
            case .views:      return NSLocalizedString("sorting.views", comment: "")
            case .favorites:  return NSLocalizedString("sorting.favorites", comment: "")
            case .topList:    return NSLocalizedString("sorting.toplist", comment: "")
            case .hot:        return NSLocalizedString("sorting.hot", comment: "")
            }
        }
    }

    enum Order: String, CaseIterable, Identifiable {
        case desc
        case asc
        var id: String { rawValue }
        var displayName: String {
            self == .desc
                ? NSLocalizedString("sorting.descending", comment: "")
                : NSLocalizedString("sorting.ascending", comment: "")
        }
    }

    enum TopRange: String, CaseIterable, Identifiable {
        case oneDay    = "1d"
        case threeDays = "3d"
        case oneWeek   = "1w"
        case oneMonth  = "1M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case oneYear   = "1y"
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .oneDay:      return NSLocalizedString("toprange.today", comment: "")
            case .threeDays:   return NSLocalizedString("toprange.last_3_days", comment: "")
            case .oneWeek:     return NSLocalizedString("toprange.last_week", comment: "")
            case .oneMonth:    return NSLocalizedString("toprange.last_month", comment: "")
            case .threeMonths: return NSLocalizedString("toprange.last_3_months", comment: "")
            case .sixMonths:   return NSLocalizedString("toprange.last_6_months", comment: "")
            case .oneYear:     return NSLocalizedString("toprange.last_year", comment: "")
            }
        }
    }

    // MARK: - Computed API Parameters

    /// Three-bit binary string, e.g. "111", "100"
    var categoriesParam: String {
        "\(general ? 1 : 0)\(anime ? 1 : 0)\(people ? 1 : 0)"
    }

    var purityParam: String {
        "\(sfw ? 1 : 0)\(sketchy ? 1 : 0)\(nsfw ? 1 : 0)"
    }

    /// Convert current filters to URL query items
    func queryItems(page: Int) -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if !query.isEmpty {
            items.append(URLQueryItem(name: "q", value: query))
        }

        items.append(URLQueryItem(name: "categories", value: categoriesParam))
        items.append(URLQueryItem(name: "purity",     value: purityParam))
        items.append(URLQueryItem(name: "sorting",    value: sorting.rawValue))
        items.append(URLQueryItem(name: "order",      value: order.rawValue))

       if sorting == .topList {
           items.append(URLQueryItem(name: "topRange", value: topRange.rawValue))
       }

        if !atLeast.isEmpty {
            items.append(URLQueryItem(name: "atleast", value: atLeast))
        }
        if !resolutions.isEmpty {
            items.append(URLQueryItem(name: "resolutions", value: resolutions))
        }
        if !ratios.isEmpty {
            items.append(URLQueryItem(name: "ratios", value: ratios))
        }
        if !selectedColor.isEmpty {
            items.append(URLQueryItem(name: "colors", value: selectedColor))
        }
        if sorting == .random, let seed = seed {
            items.append(URLQueryItem(name: "seed", value: seed))
        }

        items.append(URLQueryItem(name: "page", value: "\(page)"))

        return items
    }
}

// MARK: - Website Defaults

extension SearchFilters {
    mutating func applyWebsiteDefaults(from settings: UserSettings) {
        if !settings.categories.isEmpty {
            general = settings.categories.contains("general")
            anime   = settings.categories.contains("anime")
            people  = settings.categories.contains("people")
        }
        if !settings.purity.isEmpty {
            sfw     = settings.purity.contains("sfw")
            sketchy = settings.purity.contains("sketchy")
            nsfw    = settings.purity.contains("nsfw")
        }
        if let range = TopRange(rawValue: settings.toplistRange) {
            topRange = range
        }
        if !settings.nonEmptyResolutions.isEmpty {
            resolutions = settings.nonEmptyResolutions.joined(separator: ",")
        }
        if !settings.nonEmptyAspectRatios.isEmpty {
            ratios = settings.nonEmptyAspectRatios.joined(separator: ",")
        }
    }
}

// MARK: - Available Colors

struct WallhavenColor: Identifiable, Hashable {
    let hex: String   // without #
    var id: String { hex }
}

extension WallhavenColor {
    static let all: [WallhavenColor] = [
        "660000","990000","cc0000","cc3333","ea4c88",
        "993399","663399","333399","0066cc","0099cc",
        "66cccc","77cc33","669900","336600","666600",
        "999900","cccc33","ffff00","ffcc33","ff9900",
        "ff6600","cc6633","996633","663300","000000",
        "999999","cccccc","ffffff","424153"
    ].map { WallhavenColor(hex: $0) }
}
