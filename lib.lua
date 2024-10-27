local lastClick = 0
local interval = 0.2

local function doubleClick(mx, my, key)
	if key == 1 then
		local time = love.timer.getTime()

		if time <= lastClick + interval then
		else
			lastClick = time
		end
	end
end

-- franklin implemenation of ray method to check if
-- point is within polygon with vertices
--
-- @see https://wrfranklin.org/Research/Short_Notes/pnpoly.html
local function point_in_polygon(vertices, point)
	local contains = false
	local prev = vertices[#vertices]

	for _, vert in pairs(vertices) do
		if
			((vert.y > point.y) ~= (prev.y > point.y))
			and (point.x < (prev.x - vert.x) * (point.y - vert.y) / (prev.y - vert.y) + vert.x)
		then
			contains = not contains
		end

		prev = vert
	end

	return contains
end

return {
	point_in_polygon = point_in_polygon,
	doubleClick = doubleClick,
}
