-- todo :
-- remove images with left click
-- draw layers onscreen
-- Select tiles  to create a map
-- add camera with zoom on cursor
-- handling physics objects
-- othognal mini-map (maybe!)
local iso = require("isoMap")
local mapSize = 20
local tileWidth = 32
local tileHeight = 16
local tiles = {}
local savedTiles = {}

if love.filesystem.getInfo("tiles.lua") then
	local contents = love.filesystem.load("tiles.lua")
	savedTiles = contents()
end

love.load = function()
	iso:loadTiles(tileWidth, tileHeight, nil, nil, mapSize)
end

love.mousepressed = function(mx, my, key) end

love.keypressed = function(key)
	if key == "escape" then
	end
end

love.draw = function()
	love.graphics.clear()

	for _, tile in pairs(iso.tiles) do
		love.graphics.setColor(1, 1, 1)
		tile:drawMap()

		love.graphics.setColor(1, 0, 0)
		love.graphics.points(tile.tileX, tile.tileY)
	end

	-- for _, t in pairs(savedTiles) do
	-- 	love.graphics.draw(love.graphics.newImage(t.image), t.x, t.y, nil, nil, nil, t.ox, t.oy)
	-- end
end
