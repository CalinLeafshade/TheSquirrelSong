-- state

require("datadumper")

local state = {}

function state:new()
	self.vars = {
			started = os.time()
		}
	
end

function state:push(name, val)
	self.vars[name] = val
end

function state:get(name)
	return self.vars[name]
end

function state:save(name, slot)
	if not love.filesystem.exists("saves") then
		love.filesystem.createDirectory("saves")
	end
	local data = {
			name = name,
			slot = slot,
			saveTime = os.time(),
			data = self.vars
		}
	
	local dumped = DataDumper(data)
	love.filesystem.write("saves/save" .. slot .. ".sav", dumped)
end

function state:restore(slot)
	
end

function state:enumerate()
	local saves = love.filesystem.getDirectoryItems("saves/")
	local data = {}
	for i,v in ipairs(saves) do
		local slot = tonumber(string.sub(v,5,5))
		local ok, d = pcall(love.filesystem.load, "saves/" .. v)
		if not ok then
			error("save file is fucked yo")
		else
			local dd = d()
			table.insert(data, dd)
		end
	end
	return data 
end

return state