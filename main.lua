-- todo :
-- draw layers onscreen
-- add camera with zoom on cursor
-- handling physics objects
-- othognal mini-map (maybe!)

local iso = require("isoMap")
local mapSize = 20
local tileWidth = 32
local tileHeight = 16

love.load = function()
	iso:newMap(tileWidth, tileHeight, nil, nil, mapSize)
end

love.mousepressed = function(mx, my, key)
	iso:checkClick(mx, my, key)
end

love.keypressed = function(key)
	if key == "escape" then
		iso:saveFile("level_A")
	end
end

love.draw = function()
	love.graphics.clear()

	iso:drawMap()
end
