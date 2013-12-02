
local screen = require('screen')

local testScreen = class{ __includes = {screen} }

function testScreen:init(text, color)
	screen.init(self)
	self.text = text
	self.color = color
end

function testScreen:draw()
	local lg = love.graphics
	lg.setColor(self.color)
	lg.rectangle("fill",0,0,1920,1080)
	lg.setColor(255,255,255)
	lg.printf(self.text,0,520,1920,"center")
end

return testScreen
