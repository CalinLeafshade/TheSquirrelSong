
local mouse = {}

function mouse.getPosition()
	return mouse.getX(), mouse.getY()
end

function mouse.getX()
	return love.mouse.getX() / system.getScale()
end

function mouse.getY()
	return love.mouse.getY() / system.getScale()
end

return mouse