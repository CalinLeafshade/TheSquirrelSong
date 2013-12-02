
local screenRenderer = {
		screens = {},
		y = 0,
		target = 0,
		height = 1080,
		vel = 0,
		accel = 75,
		
	}

function screenRenderer:setScreens(screens)
	self.screens = screens
end

function screenRenderer:draw()
	for i,v in ipairs(self.screens) do
		local screenY = (i-1) * self.height - self.y
		if screenY >= -self.height and screenY < self.height then
			love.graphics.push()
			love.graphics.translate(0,screenY)
			love.graphics.setScissor(0,screenY,1920,1080)
			v:draw()
			love.graphics.setScissor()
			love.graphics.pop()
		end
	end
end



function screenRenderer:show(screen)
	local i = self:getIndex(screen)
	self.target = 1080 * (i-1)
	while math.abs(self.y - self.target) > 1 do
		coroutine.yield()
	end
end

function screenRenderer:getIndex(s)
	for i,v in ipairs(self.screens) do
		if v == s then return i end
	end
end

function screenRenderer:current()
	system.log("Current Screen", math.ceil((self.y + 1) / self.height))
	return self.screens[math.ceil((self.y + 1)/ self.height)]
end

function screenRenderer:prev()
	self.target = (self.target or 0) - 1080
end

function screenRenderer:next()
	self.target = (self.target or 0) + 1080
end

function screenRenderer:update(dt)
	local diff = math.abs(self.target - self.y)
	local intY = math.floor(self.y / 1080)
	if self.target > self.y then
		self.vel = self.vel + dt * self.accel
	elseif self.target < self.y then
		self.vel = self.vel - dt * self.accel
	end
	if math.abs(self.vel) > diff then
		self.vel = 0
		self.y = self.target
	end
	self.y = self.y + self.vel
	if intY ~= math.floor(self.y / 1080) and self.vel > 0 then
		self.vel = 0
	end
	for i,v in ipairs(self.screens) do
		v:update(dt)
		v:updateObjects(dt)
	end
	
end

return screenRenderer