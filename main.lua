--main
require('util')
class = require('hump.class')
camera = require('hump.camera')
vector = require('hump.vector')

system = 
{
	threads = {},
	debugFont = love.graphics.newFont(14),
	logs = {}
}

local test = require('testScreen')
local splash = require('splashScreen')
local renderer = require('screenrenderer')




function system.load()
	system.canvas = love.graphics.newCanvas(1920,1080)
	system.canvas:setFilter("linear","linear",16)
	system.mouse = require('mouse')
	system.screenObject = require('screenobject')
	vigScreen = require('vigscreen')
	mapScreen = require('mapscreen')
	menuScreen = require('menuscreen')
	birthScreen = require('birthscreen')
	renderer:setScreens({
			splash("gfx/splash.png"),
			menuScreen,
			test("Test 2", {255,255,0}),
			mapScreen,
			vigScreen,
			birthScreen
		})
	system.loadScenes()
	system.loadVignettes()
	--mapScreen:generateMap({system.vignettes["gent1"],system.vignettes["gent1"],system.vignettes["gent1"]})
	--system.startVignette("gent1")
end


function system.gotoMap()
	system.dispatch(
		function()
			mapScreen:clear()
			renderer:show(mapScreen)
			mapScreen:generateMap({system.vignettes["gent1"],system.vignettes["gent1"],system.vignettes["gent1"]})
			mapScreen:showMap()
		end)
end

function system.startVignette(name)
	system.dispatch( 
		function()
			vigScreen:loadVignette(name)
			renderer:show(vigScreen)
			vigScreen:showRects()
		end)
	
end

function system.newGame()
	system.state:new()
end

function system.loadDirectory(dir, callback)
	local files = love.filesystem.getDirectoryItems(dir)
	for i,v in ipairs(files) do
		local ok, chunk, result
		ok, chunk = pcall( love.filesystem.load,dir .. "/" .. v ) -- load the chunk safely
		if not ok then
		  error("syntax error in " .. v .. " " .. chunk)
		else
		assert(chunk)
		  ok, result = pcall(chunk) -- execute the chunk safely

		  if not ok then -- will be false if there is an error
			error("syntax error in " .. v .. " " .. tostring(result))
		  else
			callback(result)  
			
		  end
		end
	end
end

function system.loadVignettes()
	system.vignettes = {}
	local cb = function (result)
		system.vignettes[result.name] = result
		system.log(nil, "loaded vig: " .. result.name)
	end
	system.loadDirectory("vigs", cb)
end

function system.loadScenes()
	system.scenes = {}
	local cb = function (result)
		system.scenes[result.name] = result
		system.log(nil, "loaded scene: " .. result.name)
	end
	system.loadDirectory("scenes", cb)
end

function system.getScale()
	return love.graphics.getHeight() / 1080
end

function system.update(dt)
	system.updateCoroutines(dt)
	renderer:update(dt)
	for i,v in pairs(system.logs) do
		v.t = v.t + dt
		if v.t > 5 then
			system.logs[i] = nil
		end
	end
	system.log("FPS", love.timer.getFPS())
end

function system.draw()
	local lg = love.graphics
	lg.clear()
	lg.setCanvas(system.canvas)
	lg.clear()
	--love.graphics.push()
	--love.graphics.scale(system.getScale())
	renderer:draw()
	lg.setCanvas()
	lg.setColor(255,255,255)
	lg.draw(system.canvas,0,0,0,system.getScale(), system.getScale())
	--love.graphics.pop()
	system.drawLog()
end

function system.drawLog()
	local text = ""
	for i,v in pairs(system.logs or {}) do
		text = text .. v.text .. "\n"
	end
	love.graphics.setFont(system.debugFont)
	love.graphics.setColor(255,255,255)
	love.graphics.print(text,10,10)
end


function system.keypressed(key)
	if key == "down" then
		renderer:next()
	elseif key == "up" then
		renderer:prev()
	elseif key == "q" then
		love.event.push("quit")
	elseif key == "e" then
		system.dispatch(function() vigScreen:showRects() end)
	end
	local c = renderer:current()
	if c then c:keyPressed(key) end
end

function system.mousepressed(x,y,b)
	local c = renderer:current()
	if c then c:mousePressed(x,y,b) end
end

function system.mousereleased(x,y,b)
	local c = renderer:current()
	if c then c:mouseReleased(x,y,b) end
end

function system.isBlocked()
	local found = false
	for i,v in ipairs(system.threads) do
		if v.blocked then
			return true
		end
	end
end

function system.updateCoroutines(dt)
	for i,v in ipairs(system.threads) do
		if coroutine.status(v.co) == "dead" then
			table.remove(system.threads,i)
		else
			local result,err = coroutine.resume(v.co, dt)
			if not result then error(err) end
		end
	end
end

function system.dispatch(block,f,...)
	local args = {...}
	if type(block) == "function" then
		table.insert(args,1,f)
		f = block
		block = true
	end
	if block and system.isBlocked() then
		error("cant run two blocked threads")
	end
	local t = {block = block, co = coroutine.create(f)}
	table.insert(system.threads, t)
	local result,err = coroutine.resume(t.co, unpack(args))
	if not result then error(err) end
end

function system.waitKey(t,callback)
	local f = function(t,callback)
		local time = 0
		while time < t and not love.keyboard.isDown("escape", "return", "space") do
			time = time + coroutine.yield()
		end
		if callback then callback() end
		return time
	end
	if not coroutine.running() then
		system.dispatch(f,t,callback)
	else
		f(t,callback)
	end
end

function system.wait(t, callback)
	local f = function(t,callback)
		local time = 0
		while time < t do
			time = time + coroutine.yield()
		end
		if callback then callback() end
		return time
	end
	if not coroutine.running() then
		system.dispatch(f,t,callback)
	else
		f(t,callback)
	end
end

function system.log(token, ...)
	local t = ""
	for i,v in ipairs({...}) do
		t = t .. tostring(v) .. ","
	end
	if not token then
		token = tostring({})
	end
	system.logs[token] = {t = 0, text = token .. " " .. t}
end

local cbs = {"update","draw","keypressed","keyreleased","mousepressed", "mousereleased","load"}

for i,v in ipairs(cbs) do
	love[v] = system[v]
end
