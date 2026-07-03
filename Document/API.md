# Wallhaven API v1 Documentation

Base URL: `https://wallhaven.cc/api/v1`

---

## Table of Contents

- [Authentication](#authentication)
- [Accessing Wallpaper Information](#accessing-wallpaper-information)
- [Search and Listings](#search-and-listings)
- [Tag Info](#tag-info)
- [User Settings](#user-settings)
- [User Collections](#user-collections)
- [Rate Limiting and Errors](#rate-limiting-and-errors)

---

## Authentication

Users can authenticate by including their API key either:

1. In a request URL: `?apikey=<API_KEY>`
2. As a header: `X-API-Key: <API_KEY>`

---

## Accessing Wallpaper Information

Wallpaper info can be accessed via URL:

```
GET https://wallhaven.cc/api/v1/w/<ID>
```

NSFW wallpapers are blocked to guests. Users can access them by providing their API key:

```
GET https://wallhaven.cc/api/v1/w/<ID>?apikey=<API_KEY>
```

### Response Example

```json
{
  "data": {
    "id": "94x38z",
    "url": "https://wallhaven.cc/w/94x38z",
    "short_url": "http://whvn.cc/94x38z",
    "uploader": {
      "username": "test-user",
      "group": "User",
      "avatar": {
        "200px": "https://wallhaven.cc/images/user/avatar/200/11_3339efb2a813.png",
        "128px": "https://wallhaven.cc/images/user/avatar/128/11_3339efb2a813.png",
        "32px": "https://wallhaven.cc/images/user/avatar/32/11_3339efb2a813.png",
        "20px": "https://wallhaven.cc/images/user/avatar/20/11_3339efb2a813.png"
      }
    },
    "views": 12,
    "favorites": 0,
    "source": "",
    "purity": "sfw",
    "category": "anime",
    "dimension_x": 6742,
    "dimension_y": 3534,
    "resolution": "6742x3534",
    "ratio": "1.91",
    "file_size": 5070446,
    "file_type": "image/jpeg",
    "created_at": "2018-10-31 01:23:10",
    "colors": [
      "#000000",
      "#abbcda",
      "#424153",
      "#66cccc",
      "#333399"
    ],
    "path": "https://w.wallhaven.cc/full/94/wallhaven-94x38z.jpg",
    "thumbs": {
      "large": "https://th.wallhaven.cc/lg/94/94x38z.jpg",
      "original": "https://th.wallhaven.cc/orig/94/94x38z.jpg",
      "small": "https://th.wallhaven.cc/small/94/94x38z.jpg"
    },
    "tags": [
      {
        "id": 1,
        "name": "anime",
        "alias": "Chinese cartoons",
        "category_id": 1,
        "category": "Anime & Manga",
        "purity": "sfw",
        "created_at": "2015-01-16 02:06:45"
      }
    ]
  }
}
```

### Wallpaper Data Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique wallpaper identifier |
| `url` | string | Full URL to wallpaper page |
| `short_url` | string | Short URL |
| `uploader` | object | User info (username, group, avatar) |
| `views` | int | Number of views |
| `favorites` | int | Number of favorites |
| `source` | string | Source URL (if provided) |
| `purity` | string | `sfw`, `sketchy`, or `nsfw` |
| `category` | string | `general`, `anime`, or `people` |
| `dimension_x` | int | Width in pixels |
| `dimension_y` | int | Height in pixels |
| `resolution` | string | e.g. `"6742x3534"` |
| `ratio` | string | Aspect ratio e.g. `"1.91"` |
| `file_size` | int | File size in bytes |
| `file_type` | string | e.g. `"image/jpeg"` |
| `created_at` | string | Upload timestamp |
| `colors` | array | Top 5 dominant colors (hex) |
| `path` | string | Full resolution image URL |
| `thumbs` | object | Thumbnail URLs (`large`, `original`, `small`) |
| `tags` | array | Array of tag objects |

---

## Search and Listings

Search listings are accessed via:

```
GET https://wallhaven.cc/api/v1/search
```

If an API key is provided, searches will be performed with that user's browsing settings and default filters:

```
GET https://wallhaven.cc/api/v1/search?apikey=<API_KEY>
```

With no additional parameters, the search will display the latest SFW wallpapers.

Listings are limited to **24 results per page**. Meta information is available with each response for pagination.

### Query Parameters

| Parameter | Allowed Values | Description |
|---|---|---|
| `q` | tagname, `-tagname`, `+tag1 +tag2`, `+tag1 -tag2`, `@username`, `id:123`, `type:{png/jpg}`, `like:wallpaper ID` | Search query |
| `categories` | `100`, `101`, `111`, etc. | Toggle categories on/off (general/anime/people) |
| `purity` | `100`, `110`, `111`, etc. | Toggle purities on/off (sfw/sketchy/nsfw). NSFW requires API key |
| `sorting` | `date_added`, `relevance`, `random`, `views`, `favorites`, `toplist`, `hot` | Sort method (default: `date_added`) |
| `order` | `desc`, `asc` | Sort order (default: `desc`) |
| `topRange` | `1d`, `3d`, `1w`, `1M`, `3M`, `6M`, `1y` | Time range for toplist sorting (default: `1M`). Sorting MUST be `toplist` |
| `atleast` | `1920x1080` | Minimum resolution allowed |
| `resolutions` | `1920x1080,1920x1200` | List of exact resolutions |
| `ratios` | `16x9,16x10` | List of aspect ratios |
| `colors` | `660000`, `990000`, `cc0000`, etc. | Search by color (hex without `#`) |
| `page` | `1` - `n` | Pagination |
| `seed` | `[a-zA-Z0-9]{6}` | Optional seed for random results |

### Search Query Syntax

| Syntax | Example | Description |
|---|---|---|
| tagname | `mountains` | Search fuzzily for a tag/keyword |
| `-tagname` | `-people` | Exclude a tag/keyword |
| `+tag1 +tag2` | `+sky +clouds` | Must have tag1 AND tag2 |
| `+tag1 -tag2` | `+nature -rain` | Must have tag1 AND NOT tag2 |
| `@username` | `@john` | User uploads |
| `id:123` | `id:42` | Exact tag search (cannot be combined) |
| `type:{png/jpg}` | `type:png` | Search for file type (jpg = jpeg) |
| `like:wallpaper ID` | `like:94x38z` | Find wallpapers with similar tags |

### Categories Parameter

Each digit controls one category (general/anime/people):

| Value | general | anime | people |
|---|---|---|---|
| `100` | on | off | off |
| `010` | off | on | off |
| `001` | off | off | on |
| `110` | on | on | off |
| `101` | on | off | on |
| `011` | off | on | on |
| `111` | on | on | on |

### Purity Parameter

Each digit controls one purity level (sfw/sketchy/nsfw):

| Value | sfw | sketchy | nsfw |
|---|---|---|---|
| `100` | on | off | off |
| `110` | on | on | off |
| `101` | on | off | on |
| `111` | on | on | on |

> NSFW requires a valid API key.

### Available Colors

| | | | | |
|---|---|---|---|---|
| `660000` | `990000` | `cc0000` | `cc3333` | `ea4c88` |
| `993399` | `663399` | `333399` | `0066cc` | `0099cc` |
| `66cccc` | `77cc33` | `669900` | `336600` | `666600` |
| `999900` | `cccc33` | `ffff00` | `ffcc33` | `ff9900` |
| `ff6600` | `cc6633` | `996633` | `663300` | `000000` |
| `999999` | `cccccc` | `ffffff` | `424153` | |

### Toplist Sorting Ranges

| Value | Description |
|---|---|
| `1d` | Last 1 day |
| `3d` | Last 3 days |
| `1w` | Last 1 week |
| `1M` | Last 1 month (default) |
| `3M` | Last 3 months |
| `6M` | Last 6 months |
| `1y` | Last 1 year |

### Response Example

```json
{
  "data": [
    {
      "id": "94x38z",
      "url": "https://wallhaven.cc/w/94x38z",
      "short_url": "http://whvn.cc/94x38z",
      "views": 6,
      "favorites": 0,
      "source": "",
      "purity": "sfw",
      "category": "anime",
      "dimension_x": 6742,
      "dimension_y": 3534,
      "resolution": "6742x3534",
      "ratio": "1.91",
      "file_size": 5070446,
      "file_type": "image/jpeg",
      "created_at": "2018-10-31 01:23:10",
      "colors": ["#000000", "#abbcda", "#424153", "#66cccc", "#333399"],
      "path": "https://w.wallhaven.cc/94/wallhaven-94x38z.jpg",
      "thumbs": {
        "large": "https://th.wallhaven.cc/lg/94/94x38z.jpg",
        "original": "https://th.wallhaven.cc/orig/94/94x38z.jpg",
        "small": "https://th.wallhaven.cc/small/94/94x38z.jpg"
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 36,
    "per_page": 24,
    "total": 848,
    "query": "test",
    "seed": "abc123"
  }
}
```

> For exact tag searches (`id:##`), the `query` field will be an object: `{"id": 1, "tag": "anime"}`
>
> Sorting by `random` will produce a `seed` that can be passed between pages to ensure no repeats.

---

## Tag Info

Tag info can be queried via:

```
GET https://wallhaven.cc/api/v1/tag/<ID>
```

### Response Example

```json
{
  "data": {
    "id": 1,
    "name": "anime",
    "alias": "Chinese cartoons",
    "category_id": 1,
    "category": "Anime & Manga",
    "purity": "sfw",
    "created_at": "2015-01-16 02:06:45"
  }
}
```

### Tag Data Fields

| Field | Type | Description |
|---|---|---|
| `id` | int | Tag ID |
| `name` | string | Tag name |
| `alias` | string | Alternative name |
| `category_id` | int | Category ID |
| `category` | string | Category name |
| `purity` | string | Purity level |
| `created_at` | string | Creation timestamp |

---

## User Settings

Authenticated users can read their user settings via:

```
GET https://wallhaven.cc/api/v1/settings?apikey=<API_KEY>
```

### Response Example

```json
{
  "data": {
    "thumb_size": "orig",
    "per_page": "24",
    "purity": ["sfw", "sketchy", "nsfw"],
    "categories": ["general", "anime", "people"],
    "resolutions": ["1920x1080", "2560x1440"],
    "aspect_ratios": ["16x9"],
    "toplist_range": "6M",
    "tag_blacklist": ["blacklist tag", "another"],
    "user_blacklist": [""]
  }
}
```

### Settings Data Fields

| Field | Type | Description |
|---|---|---|
| `thumb_size` | string | Thumbnail size preference |
| `per_page` | string | Results per page |
| `purity` | array | Enabled purity levels |
| `categories` | array | Enabled categories |
| `resolutions` | array | Preferred resolutions |
| `aspect_ratios` | array | Preferred aspect ratios |
| `toplist_range` | string | Default toplist range |
| `tag_blacklist` | array | Blacklisted tags |
| `user_blacklist` | array | Blacklisted users |

---

## User Collections

### List Your Collections

```
GET https://wallhaven.cc/api/v1/collections?apikey=<API_KEY>
```

### List Another User's Collections

```
GET https://wallhaven.cc/api/v1/collections/<USERNAME>
```

Only public collections are accessible to other users. When authenticated, you can view all of your own collections.

### View Collection Contents

```
GET https://wallhaven.cc/api/v1/collections/<USERNAME>/<ID>
```

The result is a similar listing as the search results. Only the `purity` filter is available. Authenticated users can access their own private collections using their API key.

### Collections Response Example

```json
{
  "data": [
    {
      "id": 15,
      "label": "Default",
      "views": 38,
      "public": 1,
      "count": 10
    },
    {
      "id": 17,
      "label": "This is another collection",
      "views": 6,
      "public": 1,
      "count": 7
    }
  ]
}
```

### Collection Data Fields

| Field | Type | Description |
|---|---|---|
| `id` | int | Collection ID |
| `label` | string | Collection name |
| `views` | int | Number of views |
| `public` | int | `1` = public, `0` = private |
| `count` | int | Number of wallpapers |

---

## Rate Limiting and Errors

- API calls are limited to **45 per minute**
- `429` - Too many requests (rate limit exceeded)
- `401` - Unauthorized (invalid or missing API key for NSFW content)
- Any attempt to access NSFW wallpaper without a valid API key returns `401`

---

## API Endpoints Summary

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/w/{id}` | GET | Get wallpaper details |
| `/api/v1/search` | GET | Search/list wallpapers |
| `/api/v1/tag/{id}` | GET | Get tag info |
| `/api/v1/settings` | GET | Get user settings (requires API key) |
| `/api/v1/collections` | GET | List user's collections (requires API key) |
| `/api/v1/collections/{username}` | GET | List another user's public collections |
| `/api/v1/collections/{username}/{id}` | GET | List wallpapers in a collection |
