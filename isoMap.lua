-- Libraries
local ffi = require("ffi")
local lib = require("lib")
local imageSet = require("tileSet")
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
local layer = 1
local clickedImage

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
			t.image = clickedImage
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

function IsoMap.drawLayers(width, height)
	local imgX, imgY = 20, 15
	local boxW, boxH = width * 6 + 10, height * 2 + 10
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 10, 10, boxW, boxH)
	for _, set in pairs(imageSet[layer]) do
		local image = love.graphics.newImage(set)
		local imgW = image:getWidth()
		local imgH = image:getHeight()

		if imgX < boxW and imgY < boxH then
			love.graphics.draw(image, imgX, imgY, nil, 0.8, 0.8)
			imgX = imgX + image:getWidth()
		end

		if imgX >= boxW then
			imgY = imgY + image:getHeight() + 5
			imgX = 20
		end
	end
end

function IsoMap.switchLayer(key)
	if key == ">" then
		layer = layer < #imageSet and layer + 1 or 1
	elseif key == "<" then
		layer = layer > 1 and layer - 1 or 1
	end
end

function IsoMap.savedSet(mx, my)
	local x, y = 20, 15
	local boxW, boxH = 32 * 6 + 10, 32 * 2 + 10
	if mx < boxW and my < boxH then
		for _, img in pairs(imageSet[layer]) do
			if mx >= x and mx <= x + 32 and my >= y and my <= y + 32 then
				clickedImage = img
			end

			x = x + 32
			if x >= boxW then
				y = y + 32 + 5
				x = 20
			end
		end
	end
end

return IsoMap
