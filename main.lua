-- todo :
--  FIX :loading tiles from a file
require "save"

local lib = require "lib"
local mapSize = 20
local tileWidth = 32
local tileHeight = 16
local tiles = {}
local savedTiles = {}
local sx,sy = love.graphics.getPixelDimensions()

if love.filesystem.getInfo("tiles.lua") then
  local load = love.filesystem.load("tiles.lua")
  load()
end

print(#savedTiles)

local function tile(x,y,width,height,offsetX,offsetY)
  offsetX = offsetX or 10
  offsetY = offsetY or 10

  local t={
    tx=x,
    ty=y,
    hovered=false,
    drawable=true,
    image = love.graphics.newImage('tileImage.png')
  }

  function t.x()
    return (x - y) * (width/2) + offsetX
  end

  function t.y()
    return (x + y) * (height/2) + offsetY
  end

  function t.imageOffset()
    local imageOffset =  t.image:getHeight() / tileHeight
    if imageOffset == 1 then
      return 0
    end

    return t.image:getHeight()/imageOffset
  end

  function t:draw()
    -- turn the x and y points to a diamond shape
    local tx,ty = self.x(), self.y() - height/2
    local bx,by = self.x(), self.y() + height/2
    local lx,ly = self.x() - width/2 , self.y()
    local rx,ry = self.x() + width/2 , self.y()

    if self.drawable then
      if self.hovered then
        self.drawable = false
      else
        love.graphics.polygon(
          "line",
          lx,ly,
          tx,ty,
          rx,ry,
          bx,by
        )
      end
    else
      love.graphics.draw(self.image,self.x(),self.y()-self.imageOffset(),nil,nil,nil,width/2,height/2)
      table.insert(savedTiles,{
        image="tile044.png",
        x=self.x(),
        y=self.y()-self.imageOffset(),
        ox=width/2,
        oy=height/2
      })
    end

  end

  function t:checkClick(mx,my)
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

for y = 1, mapSize do
  for x = 1, mapSize do
    table.insert(tiles,tile(x,y,tileWidth,tileHeight,(sx/2), sy/2 - ((mapSize/2)*tileHeight)))
  end
end

love.mousepressed = function(mx,my,key)
  for _, tile in pairs(tiles) do
    tile:checkClick(mx,my)
  end
end

love.keypressed = function (key)
  if key == 'escape' then
    love.filesystem.write("tiles.lua",table.show(savedTiles,"savedMap"))
    love.event.quit('restart')
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


