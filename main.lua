-- todo :
-- only save files with images
-- move camera with double click?
-- zome in/out?

local iso = require "isometric.isoMap"
local tiles = require "tileSet"
local mapSize = 30
local tileWidth, tileHeight = 32, 32

love.load = function()
	iso:newMap("level_A",tiles, tileWidth, tileHeight, nil, nil, mapSize)
end

love.mousepressed = function(mx, my, key)
	iso:checkClick(mx, my, key)
	iso:saveSet(mx, my, 6, 2)
end

love.keypressed = function(key)
	iso:saveFile(key)
	iso:switchLayer(key)
end

love.draw = function()
	love.graphics.clear()
	iso:drawLayers(6, 2)
	iso:drawMap()
end
