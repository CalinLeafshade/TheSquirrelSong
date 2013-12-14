
local screenRenderer = {
		screens = {},
		y = 0,
		x = 0,
		targetY = 0,
		targetX = 0,
		height = 1080,
		vel = 0,
		accel = 75,
		
	}

function screenRenderer:setScreens(screens)
	self.screens = screens
	for i,v in ipairs(screens) do
		v.manager = self
	end
	self:current():onShow()
end

function screenRenderer:draw()
	for i,v in ipairs(self.screens) do
		local screenY = (i-1) * self.height - self.y
		if screenY > -self.height and screenY < self.height then
			love.graphics.push()
			love.graphics.translate(0,screenY)
			print(screenY)
			love.graphics.setScissor(0,screenY,1920,1080)
			local c = love.graphics.getCanvas()
			v:draw(screenY)
			assert(c == love.graphics.getCanvas(), i .. " did not reset canvas")
			love.graphics.setScissor()
			love.graphics.pop()
		end
	end
end



function screenRenderer:show(screen)
	local i = self:getIndex(screen)
	self.targetY = 1080 * (i-1)
	while math.abs(self.y - self.targetY) > 1 do
		coroutine.yield()
		system.log("loll", self.y)
	end
	self.y = self.targetY
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
	self.targetY = math.max((self.targetY or 0) - 1080,0)
end

function screenRenderer:next()
	self.targetY = math.min((self.targetY or 0) + 1080, (#self.screens - 1) * 1080)
end

function screenRenderer:left()
	self.targetX = self.targetX - 1920
end

function screenRenderer:right()
	self.targetX = self.targetX + 1920
end

function screenRenderer:update(dt)
	local diff = math.abs(self.targetY - self.y)
	local intY = math.floor(self.y / 1080)
	if self.targetY > self.y then
		self.vel = self.vel + dt * self.accel
	elseif self.targetY < self.y then
		self.vel = self.vel - dt * self.accel
	end
	if math.abs(self.vel) > diff then
		self.vel = 0
		self.y = self.targetY
		self:current():onShow()
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