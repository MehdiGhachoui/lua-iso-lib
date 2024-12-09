local next=next
local type=type
local tostring=tostring

local format=string.format

local sort=table.sort
local concat=table.concat

local function serialize(t)
	local TYPE=type(t)
	if TYPE=="boolean" or TYPE=="number" then
		return tostring(t)
	elseif TYPE=="string" then
		return format("%q",t)
	elseif TYPE=="table" then
		local ret={}
		local r_v={}
		local n=0
		for i,v in next,t do
			local sv=serialize(v)
			ret[#ret+1]=i.."="..sv
			r_v[i]=sv
			n=n+1
		end
		if n==#t then
			local tab = "savedTiles={\n"..concat(r_v,",\n").."\n}"
			tab = tab .. "\n" .. "return savedTiles"
			return tab
		else
			sort(ret)
			return "{\n"..concat(ret,",").."\n}"
		end
	else
		return "&"..TYPE.."="..format("%q",tostring(t))
	end
end

return serialize
