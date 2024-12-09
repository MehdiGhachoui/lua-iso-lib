-- Libraries
local ffi = require "ffi"
local lib = require "isometric.lib"
local save = require "isometric.save"

ffi.cdef([[
    typedef struct FILE FILE;
    FILE* fopen(const char *filename, const char *mode);
    int fprintf(FILE* stream, const char* format, ...);
    int fclose(FILE* stream);
]])

--- Calculculate the offset of an Image
--- @param image love.Image
--- @param height number
--- @return number
local function imageOffset(image, height)
	local Offset = image:getHeight() / height

	if Offset == 1 then
		return 0
	end

	return image:getHeight() / Offset
end

--- Changes the tiles to a "polygon" shape
local function pointToPoly(tile)
	local tx, ty = tile.x, tile.y - tile.height / 2
	local bx, by = tile.x, tile.y + tile.height / 2
	local lx, ly = tile.x - tile.width / 2, tile.y
	local rx, ry = tile.x + tile.width / 2, tile.y

	return {
		tx = tx,
		ty = ty,
		bx = bx,
		by = by,
		lx = lx,
		ly = ly,
		rx = rx,
		ry = ry,
	}
end

local clickedImage = nil
local layer = 1
local IsoMap = {}

--- Checks and existing map if any
--- @return table
function IsoMap:loadSavedMap()
	if love.filesystem.getInfo(self.mapName) then
		local contents = love.filesystem.load(self.mapName)
		return contents()
	end

	return {}
end

--- Create a new Isometric
--- @param mapName string
--- @param tileSet table
--- @param width number
--- @param height number
--- @param startingX number
--- @param startingY number
--- @param mapSize number
function IsoMap:newMap(mapName,tileSet, width, height, startingX, startingY, mapSize)
	local screenX, screenY = love.graphics.getPixelDimensions()

	height = height / 2
	startingX = startingY or screenX / 2
	startingY = startingY or (screenY / 2 - ((mapSize / 2) * height))

	self.tileSet = tileSet
	self.tileWidth = width
	self.tileHeight = height * 2
	self.mapName = mapName .. ".lua"

	self.tiles = self:loadSavedMap()

	if #self.tiles == 0 then
		for y = 1, mapSize do
			for x = 1, mapSize do
				table.insert(self.tiles, {
					x = (x - y) * (width / 2) + startingX,
					y = (x + y) * (height / 2) + startingY,
					width = width,
					height = height,
					active = false,
				})
			end
		end
	end
end

--- Replace tile with saved tile set with right click;
--- Undo with left click;
---	@param mx number
---	@param my number
---	@param key number
function IsoMap:checkClick(mx, my, key)
	for _, tile in pairs(self.tiles) do
		local poly = pointToPoly(tile)
		local isPointInPoly = lib.point_in_polygon({
			{ x = poly.lx, y = poly.ly },
			{ x = poly.tx, y = poly.ty },
			{ x = poly.rx, y = poly.ry },
			{ x = poly.bx, y = poly.by },
		}, { x = mx, y = my })

		if isPointInPoly then
			if key == 1 then
				tile.active = true
				tile.image = clickedImage
			else
				tile.image = nil
				tile.active = false
			end
		end
	end
end

--- Draw tiles
function IsoMap:drawMap()
	for _, t in pairs(self.tiles) do
		local poly = pointToPoly(t)

		if t.active and t.image then
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
			love.graphics.polygon("line", poly.lx, poly.ly, poly.tx, poly.ty, poly.rx, poly.ry, poly.bx, poly.by)
			love.graphics.points(t.x, t.y)
		end
	end
end

--- Save the map
--- @param key string
function IsoMap:saveFile(key)
	if key == "escape" then
		local file = ffi.C.fopen(love.filesystem.getWorkingDirectory() .. "/" .. self.mapName, "w")
		ffi.C.fprintf(file, save(self.tiles))
		ffi.C.fclose(file)

		love.event.quit("restart")
	end
end


--- Draw layers of the tileset on the top left of the screen
--- @param col number -- Number of columns of the layer
--- @param row number -- Number of rows of the layer
function IsoMap:drawLayers(col, row)
	local mouseX, mouseY = love.mouse.getPosition()
	local imgX, imgY = 15, 15
	local boxW, boxH = self.tileWidth * col + 10, self.tileHeight * row + 15

	love.graphics.rectangle("line", 10, 10, boxW, boxH)

	for _, set in pairs(self.tileSet[layer]) do
		local image = love.graphics.newImage(set)
		if imgX < boxW and imgY < boxH then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(image, imgX, imgY, nil, 0.8, 0.8)
			imgX = imgX + image:getWidth()
		end

		if imgX >= boxW then
			imgY = imgY + image:getHeight() + 5
			imgX = 15
		end
	end

	if clickedImage then
		local image = love.graphics.newImage(clickedImage)
		love.graphics.draw(image, mouseX + 5, mouseY, nil, 0.7, 0.7)
	end
end

--- Switch between layers of the tileset
--- @param key string
function IsoMap:switchLayer(key)
	if key == ">" then
		layer = layer < #self.tileSet and layer + 1 or 1
	elseif key == "<" then
		layer = layer > 1 and layer - 1 or 1
	end
end

function IsoMap:saveSet(mx, my, col, row)
	local x, y = 15, 15
	local boxW, boxH = self.tileWidth * col + 10, self.tileHeight * row + 10
	if mx < boxW and my < boxH then
		for _, img in pairs(self.tileSet[layer]) do
			if mx >= x and mx <= x + self.tileWidth and my >= y and my <= y + self.tileHeight then
				clickedImage = img
			end

			x = x + self.tileWidth
			if x >= boxW then
				y = y + self.tileHeight + 5
				x = 15
			end
		end
	end
end

return IsoMap
