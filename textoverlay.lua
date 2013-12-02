
local overlay = 
{
	font = love.graphics.newFont("fonts/border.ttf", 48)
}

function overlay:makeCanvas(wordList)
	local canvas = love.graphics.newCanvas(1920,1080)
	local lg = love.graphics
	lg.setCanvas(canvas)
	lg.setBackgroundColor(0,0,0,0)
	lg.clear()
	lg.setColor(26,20,16)
	lg.rectangle("fill", 0,0,1920,1080)
	lg.setBlendMode("replace")
	lg.setColor(0,0,0,0)
	lg.rectangle("fill", 50,50,1820, 980)
	local count = 500
	lg.setColor(0,0,0,255)
	lg.setBlendMode("subtractive")
	lg.setFont(self.font)
	for i=1,count do
		local word = tostring(table.random(wordList))
		local scale = math.random() / 2 + 0.5
		local bar = math.random()
		local x,y = 0,0
		if bar < 0.75 then
			y = math.random(self.font:getHeight(),1080 - self.font:getHeight())
			if bar < 0.335 then
				x = math.random(0,50)
			else
				local w = self.font:getWidth(word) * scale
				x = math.random(1850 - (w - 20),1900 - w)
			end
		else
			local w = self.font:getWidth(word) * scale
			x = math.random(0,1920 - w)
			if bar > 0.875 then
				y = math.random(0,50)
			else
				y = math.random(980,1080 - self.font:getHeight())
			end
		end
		
		lg.print(word,x,y,0,scale,scale)
	end
	lg.setBlendMode("alpha")
	lg.setCanvas()
	return canvas
end

function overlay:gen(wordList)
	assert(wordList, "need to pass a word list")
	local layers = 2
	self.canvasses = {}
	for i=1,layers do
		table.insert(self.canvasses, self:makeCanvas(wordList))
	end
end

function overlay:draw(cam)
	local lg = love.graphics
	lg.setColor(255,255,255)
	if self.canvasses then
		for i,v in ipairs(self.canvasses) do
			lg.draw(v,(i - 1) * (self.vigScreen.cam.x / 1920) * 20,(i - 1) * (self.vigScreen.cam.y / 1080) * 20)
		end
	end
end

return overlay