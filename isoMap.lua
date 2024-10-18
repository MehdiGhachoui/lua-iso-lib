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

local IsoMap = {}

function IsoMap:loadTiles(width, height, offsetX, offsetY, mapSize)
	local screenX, screenY = love.graphics.getPixelDimensions()

	offsetX = offsetX or screenX / 2
	offsetY = offsetY or (screenY / 2 - ((mapSize / 2) * height))
	local tileWidth = width
	local tileHeight = height
	local tileClicked = false

	self.tiles = {}

	for y = 1, mapSize do
		for x = 1, mapSize do
			table.insert(
				self.tiles,
				{ (x - y) * (width / 2) + offsetX, (x + y) * (height / 2) + offsetY, tileWidth, tileHeight, tileClicked }
			)
		end
	end
end

function IsoMap:imageOffset()
	local imageOffset = self.image:getHeight() / self.height
	if imageOffset == 1 then
		return 0
	end

	return self.image:getHeight() / self.imageOffset
end

function IsoMap:checkClick(mx, my)
	local tx, ty = self.x(), self.y() - self.height / 2
	local bx, by = self.x(), self.y() + self.height / 2
	local lx, ly = self.x() - self.width / 2, self.y()
	local rx, ry = self.x() + self.width / 2, self.y()
	return lib.point_in_polygon({
		{ x = lx, y = ly },
		{ x = tx, y = ty },
		{ x = rx, y = ry },
		{ x = bx, y = by },
	}, { x = mx, y = my })
end

function IsoMap:saveFile(savedTiles)
	local file = ffi.C.fopen(love.filesystem.getWorkingDirectory() .. "/tiles.lua", "w")
	ffi.C.fprintf(file, save(savedTiles))
	ffi.C.fclose(file)

	love.event.quit("restart")
end

function IsoMap:addTile(mx, my, key)
	-- if key == 2 then
	-- 	for k, t in pairs(savedTiles) do
	-- 		if t:checkClick(mx, my) then
	-- 			table.remove(savedTiles, k)
	-- 		end
	-- 	end
	if key == 1 then
		self.tileClicked = self:checkClick(mx, my)
	end
end

function IsoMap:drawMap()
	-- turn the x and y points to a diamond shape
	local tx, ty = self.tileX, self.tileY - self.tileHeight / 2
	local bx, by = self.tileX, self.tileY + self.tileHeight / 2
	local lx, ly = self.tileX - self.tileWidth / 2, self.tileY
	local rx, ry = self.tileX + self.tileWidth / 2, self.tileY

	if self.tileClicked then
		table.insert(self.tiles, {
			image = "tile044.png",
			x = self.tileX,
			y = self.tileY - self:imageOffset(),
			ox = self.width / 2,
			oy = self.height / 2,
		})
		self.tileClicked = false
	else
		love.graphics.polygon("line", lx, ly, tx, ty, rx, ry, bx, by)
	end
end

return IsoMap
