-- Libraries
local ffi = require("ffi")
local lib = require("lib")
local save = require("save")

ffi.cdef([[
    typedef struct FILE FILE;
    FILE* fopen(const char *filename, const char *mode);
    int fprintf(FILE* stream, const char* format, ...);
    int fclose(FILE* stream);
]])

local function imageOffset(image, height)
	local Offset = image:getHeight() / height

	if Offset == 1 then
		return 0
	end

	return image:getHeight() / Offset
end

local IsoMap = {}

function IsoMap:newMap(width, height, offsetX, offsetY, mapSize)
	local screenX, screenY = love.graphics.getPixelDimensions()
	offsetX = offsetX or screenX / 2
	offsetY = offsetY or (screenY / 2 - ((mapSize / 2) * height))

	self.tiles = {}
	for y = 1, mapSize do
		for x = 1, mapSize do
			table.insert(self.tiles, {
				x = (x - y) * (width / 2) + offsetX,
				y = (x + y) * (height / 2) + offsetY,
				width = width,
				height = height,
				active = false,
			})
		end
	end
end

function IsoMap:loadMap(mapName)
	if love.filesystem.getInfo(mapName .. ".lua") then
		local contents = love.filesystem.load(mapName .. ".lua")
		self.tiles = contents()
	end
end

function IsoMap:checkClick(mx, my, key)
	for _, tile in pairs(self.tiles) do
		local tx, ty = tile.x, tile.y - tile.height / 2
		local bx, by = tile.x, tile.y + tile.height / 2
		local lx, ly = tile.x - tile.width / 2, tile.y
		local rx, ry = tile.x + tile.width / 2, tile.y
		local isPointInPoly = lib.point_in_polygon({
			{ x = lx, y = ly },
			{ x = tx, y = ty },
			{ x = rx, y = ry },
			{ x = bx, y = by },
		}, { x = mx, y = my })

		if isPointInPoly then
			if key == 1 then
				tile.active = true
			else
				tile.image = nil
				tile.active = false
			end
		end
	end
end

function IsoMap:drawMap()
	for _, t in pairs(self.tiles) do
		-- turn the x and y points to a diamond shape tile
		local tx, ty = t.x, t.y - t.height / 2
		local bx, by = t.x, t.y + t.height / 2
		local lx, ly = t.x - t.width / 2, t.y
		local rx, ry = t.x + t.width / 2, t.y

		if t.active then
			t.image = "tile044.png"
			local tileImage = love.graphics.newImage(t.image)
			love.graphics.draw(
				tileImage,
				t.x,
				t.y - imageOffset(tileImage, t.height),
				nil,
				nil,
				nil,
				t.width / 2,
				t.height / 2
			)
		else
			love.graphics.setColor(1, 1, 1)
			love.graphics.polygon("line", lx, ly, tx, ty, rx, ry, bx, by)

			love.graphics.setColor(1, 0, 0)
			love.graphics.points(t.x, t.y)
		end
	end
end

function IsoMap:saveFile(mapName)
	local file = ffi.C.fopen(love.filesystem.getWorkingDirectory() .. "/" .. mapName .. ".lua", "w")
	ffi.C.fprintf(file, save(self.tiles))
	ffi.C.fclose(file)
end

return IsoMap
