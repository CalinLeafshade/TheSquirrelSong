-- screen

local NULLFUNC = function() end

local screen = class{
		draw = NULLFUNC,
		update = NULLFUNC,
		onShow = NULLFUNC,
		onHide = NULLFUNC,
		keyPressed = NULLFUNC,
		keyReleased = NULLFUNC
	}

function screen:init()
	self.objects = {}
end

function screen:add(o)
	table.insert(self.objects,o)
end

function screen:drawObjects()
	table.sort(self.objects, function(a,b) if a.z == b.z then return a.id > b.id else return a.z > b.z end end)
	for i,v in ipairs(self.objects) do
		if v.visible then v:draw() end
	end
end

function screen:updateObjects(dt)
	local underMouse = nil
	local mx,my = system.mouse.getPosition()
	for i=#self.objects,1,-1 do
		local v = self.objects[i]
		v:update(dt)
		if not underMouse and v:hit(mx,my) then
			underMouse = v
		end
	end
	
	if self.lastUnderMouse ~= underMouse then
		if self.lastUnderMouse then self.lastUnderMouse:onMouseLeave() end
		if underMouse then underMouse:onMouseEnter() end
	end
	
	
	self.lastUnderMouse = underMouse
	
end

function screen:mousePressed(x,y,b)
	system.log("underMouse", self.lastUnderMouse)
	if self.lastUnderMouse then
		self.lastUnderMouse:onMousePressed(b)
	end
end

function screen:mouseReleased(x,y,b)
	if self.lastUnderMouse then
		self.lastUnderMouse:onMouseReleased(b)
	end
end
	
return screen
