# yatline-page-counter.yazi
An addon to display the page count of documents in your [yatline.yazi](https://github.com/imsi32/yatline.yazi).

[!(https://github.com/PepeRoConde/yatline-page-counter.yazi/image.png)
](https://github.com/PepeRoConde/yatline-page-counter.yazi/blob/main/image.png)
## Requirements
- [yazi](https://github.com/sxyazi/yazi) version >= 0.4.0
- [yatline.yazi](https://github.com/imsi32/yatline.yazi)

## Dependencies
The following tools are used to extract page counts from different document formats:
- `pdfinfo` (from poppler-utils) - for PDF files
- `djvused` (from djvulibre-bin) - for DjVu files  
- `libreoffice` - for Office documents (optional)
- `unzip` - for EPUB and Office document processing

Install on Ubuntu/Debian:
```sh
sudo apt install poppler-utils djvulibre-bin libreoffice-core unzip
```

Install on Arch Linux:
```sh
sudo pacman -S poppler djvulibre libreoffice-fresh unzip
```

Install on macOS:
```sh
brew install poppler djvulibre libreoffice
```

## Installation
```sh
ya pack -a username/yatline-page-counter
```

## Usage
> [!IMPORTANT]
> Add this to your `~/.config/yazi/init.lua` after yatline.yazi's initialization.

```lua
require("yatline-page-counter"):setup()
```

Then, add it in one of your sections in the yatline configuration using:
```lua
{ type = "coloreds", custom = false, name = "page_count" }
```

### Configuration Options
You can customize the addon with these options:
```lua
require("yatline-page-counter"):setup({
    page_color = "cyan",           -- Color for page count display
    show_icon = true,              -- Show document icon (default: true)
    icon = "📄",                   -- Icon to display (default: 📄)
    supported_formats = {          -- File extensions to check
        "pdf", "djvu", "epub", "mobi", "azw", "azw3",
        "docx", "doc", "odt", "pptx", "ppt", "odp"
    }
})
```

### Example Configuration
```lua
require("yatline"):setup({
    -- ... your existing config ...
    status_line = {
        right = {
            section_a = {
                {type = "string", custom = false, name = "cursor_position"},
            },
            section_b = {
                {type = "coloreds", custom = false, name = "page_count"},
                {type = "coloreds", custom = false, name = "created_time"},
            },
            section_c = {
                {type = "string", custom = false, name = "hovered_file_extension", params = {true}},
                {type = "coloreds", custom = false, name = "permissions"},
            }
        }
    },
})
```

## Supported Formats
- **PDF** - Uses `pdfinfo` to get exact page count
- **DjVu** - Uses `djvused` to get exact page count  
- **EPUB/MOBI/AZW/AZW3** - Estimates page count based on HTML files
- **Office Documents** - DOCX, DOC, ODT, PPTX, PPT, ODP (estimates based on content)

## Features
- Shows page count for supported document formats when hovering
- Gracefully handles missing dependencies
- Customizable colors and icons
- Lightweight and fast execution
- Only processes files when actually needed

## Credits
- [Yazi](https://github.com/sxyazi/yazi)
- [yatline.yazi](https://github.com/imsi32/yatline.yazi)
- [yatline-created-time.yazi](https://github.com/wekauwau/yatline-created-time) - inspiration for structure
