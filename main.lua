-- todo :
-- only save files with images
-- move camera with double click?
-- zome in/out?

local iso = require "isometric.isoMap"
local tiles = require "tileSet"
local tileWidth, tileHeight = 32, 32
local shiftX,shiftY = 0,0
local movingX,movingY = 0,0
local mapSize = 30
local zoom = 1

love.load = function()
	love.window.setFullscreen(true)
end

love.mousepressed = function(mx, my, key)
	iso:checkClick(mx, my, key)
	iso:saveSet(mx, my, 6, 2)
end

love.wheelmoved = function(x,y)
	local zValue = 1.05
	if y > 0 then
			zoom = zoom * zValue
	end
	if y < 0 then
			zoom = zoom/zValue
	end
end

love.keypressed = function (key)
	iso:saveFile(key)
	iso:switchLayer(key)
	if key == "w" then
		movingX = 10
	end
	if key == "d" then
		movingX = -10
	end
	if key == "a" then
		movingY = 10
	end
	if key == "s" then
		movingY = -10
	end
end

love.keyreleased = function(key)
	if key == "w" or key == "d" then
		movingX = 0
	end
	if key == "a" or key == "s" then
		movingY = 0
	end
end

love.draw = function()
	love.graphics.clear()
	iso:drawLayers(6, 2)
	iso:drawMap()
end

love.update = function ()
	shiftX = shiftX + movingX
	shiftY = shiftY + movingY
	iso:newMap("level_A",tiles, tileWidth * zoom, tileHeight * zoom, shiftX, shiftY, mapSize)
end
