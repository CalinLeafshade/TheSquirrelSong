
local NULLFUNC = function() end

local screenObject = class
{
	x,y,z = 0,0,0,
	update = NULLFUNC,
	draw = NULLFUNC,
	hit = NULLFUNC,
	onMouseEnter = NULLFUNC,
	onMouseLeave = NULLFUNC,
	onMousePress = NULLFUNC,
	onMouseReleased = NULLFUNC,
	visible = true,
	events = {}
}

function screenObject:fireEvent(e, ...)
	for i,v in ipairs(self.events[e] or {}) do
		v(...)
	end
end

function screenObject:hookEvent(e, f)
	self.events[e] = self.events[e] or {}
	table.insert(self.events[e], f)
end

function screenObject:init()
	self.id = tostring({})
	self.events = {}
end

return screenObject

