function hovered()
	local hovered = cx.active.current.hovered
	if hovered then
		return hovered
	else
		return ""
	end
end

local function get_pdf_pages(filepath)
	-- Use pdfinfo to get page count (from poppler-utils)
	local handle = io.popen("pdfinfo '" .. filepath .. "' 2>/dev/null | grep 'Pages:' | awk '{print $2}'")
	if handle then
		local result = handle:read("*a")
		handle:close()
		local pages = tonumber(result:match("%d+"))
		return pages
	end
	return nil
end

local function get_djvu_pages(filepath)
	-- Use djvused to get page count for DjVu files
	local handle = io.popen("djvused '" .. filepath .. "' -e 'n' 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		local pages = tonumber(result:match("%d+"))
		return pages
	end
	return nil
end

local function get_epub_pages(filepath)
	-- Basic EPUB page estimation (not exact, but gives an idea)
	local handle = io.popen("unzip -l '" .. filepath .. "' 2>/dev/null | grep -c '\\.xhtml\\|\\.html' 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		local pages = tonumber(result:match("%d+"))
		-- Rough estimation: each HTML file is about 2-3 pages
		return pages and (pages * 2) or nil
	end
	return nil
end

local function get_office_pages(filepath, filetype)
	-- Use libreoffice to get page count for office documents
	local cmd = ""
	if filetype == "docx" or filetype == "doc" or filetype == "odt" then
		cmd = "libreoffice --headless --cat '" .. filepath .. "' 2>/dev/null | wc -l"
	elseif filetype == "pptx" or filetype == "ppt" or filetype == "odp" then
		-- For presentations, count slides
		cmd = "unzip -l '" .. filepath .. "' 2>/dev/null | grep -c 'slide[0-9]\\+\\.xml' 2>/dev/null"
	end
	
	if cmd ~= "" then
		local handle = io.popen(cmd)
		if handle then
			local result = handle:read("*a")
			handle:close()
			local count = tonumber(result:match("%d+"))
			if filetype == "docx" or filetype == "doc" or filetype == "odt" then
				-- Rough estimation: 50 lines per page
				return count and math.ceil(count / 50) or nil
			else
				return count
			end
		end
	end
	return nil
end

local function setup(_, options)
	options = options or {}
	local config = {
		page_color = options.page_color or "cyan",
		show_icon = options.show_icon ~= false, -- default true
		icon = options.icon or "📄",
		supported_formats = options.supported_formats or {
			"pdf", "djvu", "epub", "mobi", "azw", "azw3",
			"docx", "doc", "odt", "pptx", "ppt", "odp"
		}
	}
	
	-- Create a set for faster lookup
	local format_set = {}
	for _, format in ipairs(config.supported_formats) do
		format_set[format:lower()] = true
	end
	
	if Yatline ~= nil then
		function Yatline.coloreds.get:page_count()
			local h = hovered()
			local page_info = {}
			
			-- Check if file is hovered and is a regular file
			if not h or not h.cha or h.cha.is_dir then
				return page_info
			end
			
			local filepath = tostring(h.url)
			local filename = h.name:lower()
			local extension = filename:match("%.([^%.]+)$")
			
			if not extension or not format_set[extension] then
				return page_info
			end
			
			local pages = nil
			
			-- Get page count based on file type
			if extension == "pdf" then
				pages = get_pdf_pages(filepath)
			elseif extension == "djvu" then
				pages = get_djvu_pages(filepath)
			elseif extension == "epub" or extension == "mobi" or extension == "azw" or extension == "azw3" then
				pages = get_epub_pages(filepath)
			elseif format_set[extension] then
				pages = get_office_pages(filepath, extension)
			end
			
			if pages and pages > 0 then
				local text = ""
				if config.show_icon then
					text = config.icon .. " " .. pages .. "p"
				else
					text = pages .. " pages"
				end
				table.insert(page_info, { " " .. text .. " ", config.page_color })
			end
			
			return page_info
		end
	end
end

return { setup = setup }
