
local mapScreen = require('screen')()

local maps = require('maps')

mapScreen.cam = camera(0,0)
mapScreen.time = 0
mapScreen.font = love.graphics.newFont("fonts/border.ttf",48)
mapScreen.bits = {}

local spot = love.graphics.newImage("gfx/out.png")
local paper = love.graphics.newImage("gfx/paper.png")
paper:setWrap("repeat","repeat")
local paperQuad = love.graphics.newQuad(0,0,paper:getWidth() * 3, paper:getHeight() * 3, paper:getWidth(), paper:getHeight())

local vigTypes = {
		romantic = {
				icon = love.graphics.newImage("gfx/heart.png"),
				hue = 300 * (256 / 360),
				sat = { 128,255 },
				lit = 180
			},
		intellectual = {
				icon = love.graphics.newImage("gfx/bulb.png"),
				hue = 59 * (256 / 360),
				sat = { 128,255 },
				lit = 180
			},
		general = {
				icon = love.graphics.newImage("gfx/star.png"),
				hue = 178 * (256 / 360),
				sat = { 128,255 },
				lit = 180
			},
	}

function mapScreen:registerSpot(size, x,y,col,text,link)
	table.insert(self.spots, { size = size, x = x, y = y, color = col,text = text, link = link} )
	
end

function mapScreen:generateMap(vigList)
	
	local function addToEnd(branch, node)	
		while branch[1] do
			branch = branch[1]
		end
		table.insert(branch,node)
		return node
	end
	
	local function add(branch, node)
		table.insert(branch,node)
		return node
	end
	
	local colors = {}
	
	local start = math.random(255)
	local sat = math.random(80,255)
	local lit = math.random(100,200)
	local diff = math.random(20,255/#vigList)
	
	for i=1, #vigList do
		table.insert(colors, {HSL(start,sat,lit)})
		start = (start + diff) % 255
	end
	
	colors = table.shuffled({ {137,78,36},{220,36,31},{255,206,0},{0,114,41},{255,102,0},{215,153,175},{134,143,152},{117,16,86},{0,0,0},{0,25,168},{0,160,226} })
	
	local function randomColor()
		return table.remove(colors,1)
	end
	
	local count = #vigList
	--local map = deepcopy(table.random(maps[count]))
	
	local map = {
					length = {700, 800},
					angle = "forward",
					color = {0,0,0}
				}
				
	
	local firstSpot = addToEnd(map, { type = "spot" })
	
	local ud = table.random({"up","down"})
	if count == 1 then
		map.length = {1200,1500}
		firstSpot.link = true 
	end
	if count > 1 then
		local f = add( firstSpot, { length = {400,700}, angle = "forward", color = randomColor()})
		if math.random() > 0.5 then
			add(f,  { type = "spot", link = true})
		else
			add(
				add(f, { length = {100,150}, angle = {"up", "down"}}),
				{ length = {250,500}, angle = "forward", { type = "spot", link = true}})
		end
		add( add(firstSpot, { length = math.random(250,550), angle = ud, color = randomColor()}), { length = {300,700}, angle = "forward", { type = "spot", link = true }})
	end
	if count > 2 then
		add( add(firstSpot, { length = math.random(250,550), angle = ud == "up" and "down" or "up", color = randomColor()}), { length = {300,700}, angle = "forward", { type = "spot", link = true }})
	end
	
	
	local function processMapBranch(m, vigList)
		
		if m.length then
			if type(m.length) == "number" then
				m.length = m.length * (1 + (math.random() / 5 - 0.1))
			elseif type(m.length) == "table" then
				m.length = math.random(m.length[1], m.length[2])
			end
		end
		if type(m.angle) == "table" then
			m.angle = table.random(m.angle)
		end
		if m.link then
			m.link = vigList[1].name
			m.text = vigList[1].title
			table.remove(vigList[1],1)
		end
	
		for i,v in ipairs(m) do
			processMapBranch(v, vigList)
		end
	end
	
	local vList = {}
	for i,v in ipairs(vigList) do
		vList[i] = v
	end
	
	processMapBranch(map, vList)
	self.map = map
end

function mapScreen:drawSpots()
	for i,v in ipairs(self.spots) do
		v.size = v.size * 0.5
		if self.selected == i then
			v.size = v.size * 2
		end
		love.graphics.setBlendMode("premultiplied")
		love.graphics.setColor(v.color)
		love.graphics.draw(spot,v.x,v.y,0,v.size,v.size,64,64)
		--love.graphics.circle("fill",v.x,v.y,v.size,16,128)
		love.graphics.setColor(255,255,255)
		love.graphics.draw(spot,v.x,v.y,0,v.size * 0.6,v.size * 0.6,64,64)
		love.graphics.setBlendMode("alpha")
		--love.graphics.circle("fill",v.x,v.y,v.size * 0.6,16,128)
		if self.time > 0.8 then
			love.graphics.setColor(0,0,0)
			local t = (self.time - 0.8) * 5
			love.graphics.setFont(self.font)
			local scale = outSine(t,0,1,1,1,0.3)
			local w = self.font:getWidth(v.text)
			love.graphics.print(v.text,v.x,v.y + self.font:getHeight(),0,scale,scale,w/2,self.font:getHeight() /2)
		end
	end
	
end

function mapScreen:newBit(x,y,t)
	local hue = type(t.hue) == "number" and t.hue or math.random(t.hue[1], t.hue[2])
	local sat = type(t.sat) == "number" and t.sat or math.random(t.sat[1], t.sat[2])
	local lit = type(t.lit) == "number" and t.lit or math.random(t.lit[1], t.lit[2])
	--sat = 0
	local item = 
	{
		position = vector(x,y),
		velocity = vector((math.random() * (math.pi * 2) - math.pi) * 0.5,(-math.random() - 1) * 3) * 100,
		icon = t.icon,
		rotation = math.random() * math.pi,
		rotationalSpeed = math.random() * math.pi * 4,
		scale = math.random() * 0.2 + 0.1,
		color = {HSL(hue,sat,lit)},
		time = love.timer.getTime()
	}
	table.insert(self.bits, item)
end

function mapScreen:blowOut(x,y,ty)
	self.lastBlowOut = love.timer.getTime()
	ty = table.random({"general","romantic","intellectual"})
	if type(ty) == "string" then ty = vigTypes[ty] end
	assert(ty, "type given invalid")
	system.dispatch(false, function()
				local t = 0
				local lastItem = 0.1
				while t < 1 do
					while lastItem > 0.05 do
						lastItem = lastItem - 0.05
						mapScreen:newBit(x,y,ty)
					end
					local dt = coroutine.yield()
					lastItem = lastItem + dt
					t = t + dt
				end
			
			end)
end

function mapScreen:drawBits(overSpots)
	for i,v in ipairs(self.bits or {}) do
		if not overSpots or v.velocity.y > 0 then
			love.graphics.setColor(v.color)
			love.graphics.draw(v.icon, v.position.x, v.position.y, v.rotation, v.scale, v.scale, v.icon:getWidth() /2 , v.icon:getHeight() / 2)
		end
	end
end

function mapScreen:updateBits(dt)
	for i,v in ipairs(self.bits or {}) do
		v.velocity = v.velocity + vector(0,500) * dt
		v.position = v.position + v.velocity * dt
		v.rotation = v.rotation + v.rotationalSpeed * dt
		if v.position.y > 1200 then
			table.remove(self.bits,i)
		end
	end
end

function mapScreen:draw()
	local lg = love.graphics
	lg.setColor({255,255,255})
	lg.rectangle("fill",0,0,1920,1080)
	
	lg.setLineWidth(16)
	self.cam:attach()
	lg.draw(paper,paperQuad,0,-600)
	self.spots = {}
	local function drawBranch(sx,sy,b,energy)
		local t = b.type or "line"
		local dx,dy = sx,sy
		if b.color then
			lg.setColor(b.color)
		end
		if t == "line" then
			
			
			if b.angle == "forward" then
				dx = sx + math.min(energy, b.length)
			elseif b.angle == "up" then
				dx = sx + math.min(energy, b.length) * math.sin(math.pi / 4)
				dy = sy - math.min(energy, b.length) * math.cos(math.pi / 4)
			elseif b.angle == "down" then
				dx = sx + math.min(energy, b.length) * math.sin(math.pi / 4 + math.pi / 2)
				dy = sy - math.min(energy, b.length) * math.cos(math.pi / 4 + math.pi / 2)
			end
			
			lg.line(sx,sy,dx,dy)
			lg.circle("fill",dx,dy,8,16)
		elseif t == "spot" then
			local size = outElastic(math.min(energy, 500) / 500,0,1,1,1,0.3)
			--size = lerp(0,1,size)
			--local size = berp(0,24,math.min(energy, 100) / 100)
			
			mapScreen:registerSpot(size,dx,dy,{lg.getColor()},b.text or "",b.link)
			
		end
		
		energy = math.max(energy - (b.length or 500),0)
		if energy > 0 then
			for i,v in ipairs(b) do
				drawBranch(dx,dy,v,energy)
			end
		end
	end
	lg.push()
	--lg.translate(0,1080 / 2)
	local energy = self.energy
	
	if self.map then drawBranch(0,0, self.map, energy) end
	self:drawBits(false)
	self:drawSpots()
	self:drawBits(true)
	
	lg.pop()
	self.cam:detach()
end

function mapScreen:mousePressed(x,y,b)
	if self.selected > -1 then
		system.startVignette(self.spots[self.selected].link)
	end
end

function mapScreen:update(dt)
	self.energy = lerp(0,3000,self.time)
	self.cam.x = 600 + smoothlerp(0,800,self.time)
	self.cam:zoomTo(smoothlerp(2,1,self.time))
	local mx,my = system.mouse.getPosition()
	mx,my = self.cam:worldCoords(mx,my)
	--mx = mx - 300
	--my = my - 180
	local lastSelected = self.selected or -1
	self.selected = -1
	for i,v in ipairs(self.spots or {}) do
		if math.abs(v.x - mx) < 50 and math.abs(v.y - my) < 50 and v.link then
			self.selected = i
		end
	end
	if self.selected > -1 then-- and self.selected ~= lastSelected then -- and love.timer.getTime() - (self.lastBlowOut or 0) > 5 then
		local x,y = self.spots[self.selected].x, self.spots[self.selected].y
		local ty = system.vignettes[self.spots[self.selected].link].type or table.random({"general","romantic","intellectual"})
		if type(ty) == "string" then ty = vigTypes[ty] end
		self.lastBit = self.lastBit or 0
		self.lastBit = self.lastBit + dt
		system.log("lol", self.lastBit)
		while self.lastBit > 0.05 do
			self:newBit(x,y,ty)
			self.lastBit = self.lastBit - 0.05
		end
		--self:blowOut(self.spots[self.selected].x, self.spots[self.selected].y, "general")
	end
	self:updateBits(dt)
end

function mapScreen:showMap()
	local i = 0
	while i < 1 do
		mapScreen.time = i
		i = i + coroutine.yield() / 2
	end
end

function mapScreen:clear()
	self.map = nil
	self.time = 0
end


function mapScreen:keyPressed(key)
	if key == "r" then
		local list = {}
		for i=1,math.random(1,3) do
			list[i] = system.vignettes["gent1"]
		end
		self:generateMap(list)
		system.dispatch(function()
			local i = 0
			while i < 1 do
				mapScreen.time = i
				i = i + coroutine.yield() / 2
			end
		end)
	end
end

return mapScreen

