-- todo :
-- loading tile set (.PNG) from table to UI element; tileSet = { layer_name={ list_of_pngs } }
-- Select tiles (.PNG) from UI to create a map
-- add camera with zoom on cursor
-- handling physics objects
-- othognal mini-map (maybe!)

local ffi = require "ffi"
local lib = require "lib"
local save = require "save"

local mapSize = 20
local tileWidth = 32
local tileHeight = 16
local tiles = {}
local savedTiles = {}
local sx,sy = love.graphics.getPixelDimensions()

ffi.cdef([[
    typedef struct FILE FILE;
    FILE* fopen(const char *filename, const char *mode);
    int fprintf(FILE* stream, const char* format, ...);
    int fclose(FILE* stream);
]])

if love.filesystem.getInfo("tiles.lua") then
  local contents=love.filesystem.load("tiles.lua")
  savedTiles = contents()
end

local function tile(x,y,width,height,offsetX,offsetY)
  offsetX = offsetX or 10
  offsetY = offsetY or 10

  local t={
    tx=x,
    ty=y,
    hovered=false,
    drawable=true,
    image = love.graphics.newImage('tile044.png')
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

  function t:drawIso()
    -- turn the x and y points to a diamond shape
    local tx,ty = self.x(), self.y() - height/2
    local bx,by = self.x(), self.y() + height/2
    local lx,ly = self.x() - width/2 , self.y()
    local rx,ry = self.x() + width/2 , self.y()

    if self.hovered then
      table.insert(savedTiles,{
        image="tile044.png",
        x=self.x(),
        y=self.y()-self.imageOffset(),
        ox=width/2,
        oy=height/2
      })
      self.hovered = false
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
    local file = ffi.C.fopen(love.filesystem.getWorkingDirectory(), "w")
    ffi.C.fprintf(file, save(savedTiles))
    ffi.C.fclose(file)

    love.event.quit('restart')
  end
end

love.draw = function ()
  love.graphics.clear()
  for _, tile in pairs(tiles) do
    love.graphics.setColor(1,1,1)
    tile:drawIso()

    love.graphics.setColor(1,0,0)
    love.graphics.points(tile.x(), tile.y())
  end

  for _, t in pairs(savedTiles) do
    love.graphics.draw(love.graphics.newImage(t.image),t.x,t.y,nil,nil,nil,t.ox,t.oy)
  end
end


