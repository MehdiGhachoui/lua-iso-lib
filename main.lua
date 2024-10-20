-- todo :
-- add camera with zoom on cursor

local iso = require("isoMap")
local mapSize = 20
local tileWidth, tileHeight = 32, 32

love.load = function()
	iso:newMap(tileWidth, tileHeight / 2, nil, nil, mapSize)
end

love.mousepressed = function(mx, my, key)
	iso:checkClick(mx, my, key)
	iso.savedSet(mx, my)
end

love.keypressed = function(key)
	if key == "escape" then
		iso:saveFile("level_A")
	end
	iso.switchLayer(key)
end

love.draw = function()
	love.graphics.clear()

	iso.drawLayers(tileWidth, tileHeight)
	iso:drawMap()
end
