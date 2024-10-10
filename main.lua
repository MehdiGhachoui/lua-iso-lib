-- todo :
-- manualy add sprites
-- limit action (draw,click,..) to the map
-- save sprites in a file (load them next time)
local lib = require "lib"
local mapSize = 20
local tileWidth = 64
local tileHeight = 32

local tiles = {}
local sx,sy = love.graphics.getPixelDimensions()
local function tile(x,y,width,height,offsetX,offsetY)
  offsetX = offsetX or 10
  offsetY = offsetY or 10

  local t={tx=x,ty=y,hovered=false}

  function t.x()
    return (x + y) *(width/2) + offsetX
  end

  function t.y()
    return (x - y) * (height/2) + offsetY
  end

  function t:draw()
    local tx,ty = self.x(), self.y() - height/2
    local bx,by = self.x(), self.y() + height/2
    local lx,ly = self.x() - width/2 , self.y()
    local rx,ry = self.x() + width/2 , self.y()

    if self.hovered then
      love.graphics.polygon(
        "fill",
        lx,ly,
        tx,ty,
        rx,ry,
        bx,by
      )
    else
      love.graphics.polygon(
        "line",
        lx,ly,
        tx,ty,
        rx,ry,
        bx,by
      )
    end

  end

  function t:checkHover(mx,my)
    local tx,ty = self.x(), self.y() - height/2
    local bx,by = self.x(), self.y() + height/2
    local lx,ly = self.x() - width/2 , self.y()
    local rx,ry = self.x() + width/2 , self.y()
    self.hovered = lib.point_in_polygon(
      {
        {x=lx,y=ly},
        {x=tx,y=ty},
        {x=rx,y=ry},
        {x=bx,y=by}
      },
      {x=mx,y=my}

    )
  end

  return t
end

for x = 1, mapSize do
  for y = 1, mapSize do
    table.insert(tiles,tile(x,y,tileWidth,tileHeight,(sx/2)- ((mapSize/2)*tileWidth), sy/2))
  end
end

love.mousemoved = function(mx,my)
  for _, tile in pairs(tiles) do
    tile:checkHover(mx,my)
  end
end

love.draw = function ()
  love.graphics.clear()

  for _, tile in pairs(tiles) do
    love.graphics.setColor(1,1,1)
    tile:draw()

    love.graphics.setColor(1,0,0)
    love.graphics.points(tile.x(), tile.y())
  end
end


