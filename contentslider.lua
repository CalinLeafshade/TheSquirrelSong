
local contentSlider = system.screenObject()

contentSlider.x = 170
contentSlider.y = 350
contentSlider.width = 300
contentSlider.height = 500
contentSlider.translation = 0
contentSlider.targetTranslation = 0
contentSlider.font = love.graphics.newFont("fonts/DroidSans.ttf",21)

contentSlider.slides = {
		"This is a slide",
		"As is this.",
		"Gosh, yet another slide"
	}

function contentSlider:setNode(node)
	self.slides = {}
	self.translation = 0
	self.targetTranslation = 0
	local allText = true
	for i,v in ipairs(node) do
		self.slides[i] = v
		if type(v) ~= "string" then
			allText = false
		end
	end
	if allText then
		self.slides[#self.slides] = { type = "end", text = self.slides[#self.slides] }
	end
end

function contentSlider:currentPage()
	return math.floor(self.targetTranslation / self.width) + 1
end

function contentSlider:hit(x,y)
	return x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
end

function contentSlider:onMousePressed()
	local mx,my = system.mouse.getPosition()
	self.grabbed = {mx,self.translation}
	system.log("grabbed", "yes")
	self.mousedSelected = self.selected
end

function contentSlider:onMouseReleased()
	if self.mousedSelected and self.mousedSelected == self.selected and math.abs(self.translation - self.targetTranslation) < 10 then
		local i = self.selected
		if self.hotspots[i].type and self.hotspots[i].type == "end" then
			self:fireEvent("choiceSelected", "return")
		else
			self:fireEvent("choiceSelected", self.selected)
		end
	end
end

function contentSlider:release()
	self.grabbed = false
	if self.translation - self.targetTranslation > self.width / 2 then
		self.targetTranslation = math.min(self.targetTranslation + self.width,#self.slides * self.width)
	elseif self.translation - self.targetTranslation < -self.width / 2 then
		self.targetTranslation = math.max(self.targetTranslation - self.width,0)
	end
end

function contentSlider:update(dt)
	if not love.mouse.isDown("l") and self.grabbed then
		self:release()
	end
	if self.grabbed then
		local mx,my = system.mouse.getPosition()
		self.translation = clamp(clamp(self.grabbed[2] + self.grabbed[1] - mx, self.targetTranslation - self.width, self.targetTranslation + self.width),0,(#self.slides - 1) * self.width)
	else
		self.translation = lerp(self.translation, self.targetTranslation, dt * 5)
	end
	self.selected = nil
	if self.hotspots then
		local mx,my = system.mouse.getPosition()
		for i,v in ipairs(self.hotspots) do
			local x,y,w,h = v[1] + -self.translation + self.x + 10, v[2] + self.y, v[3], v[4]
			if contains(mx,my,x,y,w,h) then
				self.selected = i
			end
		end
	end
	
end

function contentSlider:drawSlide(s,x)
	local lg = love.graphics
	self.hotspots = nil
	if type(s) == "string" then
		lg.printf(s,x,0,self.width)
	elseif type(s) == "table" then
		if s.type == "choice" then
			lg.printf(s.text,x,0,self.width)
			local _, h = self.font:getWrap(s.text, self.width) 
			h = h * self.font:getHeight()
			local y = h + self.font:getHeight()
						
			self.hotspots = {}
			for i,v in ipairs(s.choices) do
				self.hotspots[i] = {x + 30, y, self.font:getWidth(v.text), self.font:getHeight()}
				local c = self.selected == i and {0,0,0} or {128,128,128}
				lg.setColor(c)
				lg.print(v.text, x + 30, y)
				y = y + self.font:getHeight()
			end
		elseif s.type == "end" then
			lg.printf(s.text,x,0,self.width)
			local _, h = self.font:getWrap(s.text, self.width) 
			h = h * self.font:getHeight()
			local y = h + self.font:getHeight()
			self.hotspots = { { type = "end", x + 30, y, self.font:getWidth("Return"), self.font:getHeight()} }
			local c = self.selected == 1 and {0,0,0} or {128,128,128}
			lg.setColor(c)
			lg.print("Return", x + 30, y)
		end	
	end
end

function contentSlider:draw()
	local lg = love.graphics
	local s = system.getScale()
	lg.setScissor(self.x,self.y,self.width, self.height)
	lg.push()
	lg.translate(-self.translation + self.x + 10,self.y)
	lg.setFont(self.font)
	lg.setColor(0,0,0)
	for i,v in ipairs(self.slides) do
		local x = (i-1) * self.width
		self:drawSlide(v,x)
	end
	lg.pop()
	lg.setScissor()
end


return contentSlider