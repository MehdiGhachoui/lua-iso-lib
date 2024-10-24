-- todo :
-- move camera with double click
-- zome in/out ?

local iso = require("isoMap")
local lib = require("lib")
local mapSize = 30
local tileWidth, tileHeight = 32, 32

love.load = function()
	iso:newMap(tileWidth, tileHeight, nil, nil, mapSize)
end

love.mousepressed = function(mx, my, key)
	iso:checkClick(mx, my, key)
	iso:saveSet(mx, my, 6, 2)
	lib.doubleClick(key)
end

love.keypressed = function(key)
	if key == "escape" then
		iso:saveFile("level_A")
	end
	iso.switchLayer(key)
end

love.draw = function()
	love.graphics.clear()

	iso:drawLayers(6, 2)
	iso:drawMap()
end
