--menu screen

local screen = require('screen')

local menuScreen = screen()

local target = 0
local accel = 50
local vel = 0
local xOffset = 0
local lg = love.graphics
local background = lg.newImage("gfx/menu/background.png")
local font = lg.newFont("fonts/DroidSans.ttf", 40)
local selectedFont = lg.newFont("fonts/DroidSans.ttf", 55)

local windowMode = 1

local optionsMenu = function()
		return {
				x = 1920,
				items = 
				{
					{ text = "Window Mode", options = { "Windowed", "Fullscreen", "Fullscreen Borderless" }, selected = windowMode, onChange = function(self, value) windowMode = math.max(value % 4,1) end },
					{ text = "Return", onSelected = function() menuScreen:showMenu(1) end}
				}	
			}
	end

local mainMenu = 
{
	x = 0,
	items = 
		{
			{text = "New Game", onSelected = function() end},
			{text = "Load Game", onSelected = function() end},
			{text = "Options", onSelected = function() menuScreen:showMenu(optionsMenu) end},
			{text = "Quit", onSelected = function() system.quit() end},
		}
}





menuScreen.menus = {mainMenu,optionsMenu}
local selected = nil

function menuScreen:showMenu(menu)
	if type(menu) == "function" then
		menu = menu()
	elseif type(menu) == "number" then
		menu = self.menus[menu]
	end
	target = menu.x
end

function menuScreen:update(dt)
	local diff = math.abs(target - xOffset)
	local intY = math.floor(xOffset / 1920)
	if target > xOffset then
		vel = vel + dt * accel
	elseif target < xOffset then
		vel = vel - dt * accel
	end
	if math.abs(vel) > diff then
		vel = 0
		xOffset = target
	end
	xOffset = xOffset + vel
	system.log("x", xOffset)
end

function menuScreen:drawMenu(m)
	if type(m) == "function" then
		m = m()
	end
	local x = 1920 / 2 + m.x - xOffset
	local y = 400
	lg.setFont(font)
	for i,v in ipairs(m.items) do
		local mx,my = system.mouse:getPosition()
		mx = mx + xOffset
		local f = font
		if mx > (1920 / 2 - 500) + xOffset and mx < (1920 / 2 + 500) + xOffset and my > y and my < y + selectedFont:getHeight() then
			f = selectedFont
			selected = v
		end
		lg.setFont(f)
		local text = v.text
		if v.options then
			text = v.text .. " - " .. v.options[v.selected]
		end
		lg.printf(text,x - 500, y, 1000, "center")
		y = y + f:getHeight() + 10
	end
end

function menuScreen:mousePressed(x,y,b)
	if selected then
		if selected.options then
			selected:onChange(selected.selected + 1)
		elseif selected.onSelected then
			selected:onSelected()
		end
	end
end

function menuScreen:draw()
	lg.draw(background,0,0)
	for i,v in ipairs(self.menus) do
		self:drawMenu(v)
	end
end

return menuScreen