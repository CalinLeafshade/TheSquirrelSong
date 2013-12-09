
local screen = require('screen')

local splashScreen = class{ __includes = {screen} }

function splashScreen:init(image)
	screen.init(self)
	if type(image) == "string" then
		image = love.graphics.newImage(image)
	end
	self.image = image
end

function splashScreen:draw()
	local lg = love.graphics
	lg.setColor(0,0,0)
	lg.rectangle("fill",0,0,1920,1080)
	lg.setColor(255,255,255)
	lg.draw(self.image,1920 / 2, 1080 / 2, 0, 1, 1, self.image:getWidth() / 2 , self.image:getHeight() / 2)
end

function splashScreen:onShow()
	system.waitKey(3, function() self.manager:next() end)
end

return splashScreen
