local vigScreen = require('screen')()



local overlay = require('textoverlay')

vigScreen.cam = { x = 0, y = 0, z = 0, vanishingPointX = 3.7, vanishingPointY = 0, focalLength = 6 }
vigScreen.guiRects = {}

local slider = require('contentslider')
slider.visible = false
vigScreen:add(slider)

slider:hookEvent("choiceSelected", function(choice)
			if type(choice) == "string" and choice == "return" then
				system.gotoMap()
				return
			end
			choice = vigScreen.node[#vigScreen.node].choices[choice]
			local gt = choice.gotoNode
			if type(gt) == "function" then
				gt = gt()
			end
			system.dispatch(function() vigScreen:showNode(gt) end)
		end)

vigScreen.fonts = {
		title = love.graphics.newFont("fonts/vigtitle.ttf",80),
		subtitle = love.graphics.newFont("fonts/vigsubtitle.ttf", 32),
		body = love.graphics.newFont("fonts/vigbody.ttf", 16)
	
	}

function vigScreen.cam:calculate(x, y, z)
	local scale = self.focalLength/z
	print("scale",scale)
	local newX = (x - self.x) * scale
	local newY = (y - self.y) * scale
	return newX, newY, scale
end

function vigScreen:loadScene(def)
	if type(def) == "string" then
		def = system.scenes[def]
	end
	assert(def, "scene is nil")
	self.scene = def
	self.roomObjects = {}
	for i,v in ipairs(def.objects) do
		local t = {
				sprite = love.graphics.newImage("gfx/roomobjects/" .. v.filename),
				pos = v.coords,
				id = tostring({})
			}
		table.insert(self.roomObjects, t)
	end
	overlay:gen({ "memories", "life", "path", "friendship", "is", "magic", "love", "sex", "wants", "needs", "fears", "hopes", "summer", "winter", "autumn", "spring", "beautiful", "senseless", "captivating", "dreams", "prospect", "light", "goal", "fortune", "greed", "despair", "belief", "angst", "worry", "concern", "family", "friends", "music", "cold", "warm" })
	overlay.vigScreen = self
end

function vigScreen:loadVignette(vig)
	if type(vig) == "string" then
		vig = system.vignettes[vig]
	end
	assert(vig, "vignette is nil")
	self.vig = vig
	self:loadScene(vig.scene)
	self.rects = nil
	self.textShown = false
	vigScreen:showNode(1)
end

function vigScreen:showNode(n)
	self.nodeIndex = n
	self.node = self.vig.nodes[self.nodeIndex]
	assert(self.node)
	slider:setNode(self.node)
	system.log(nil,"show node")
end

function vigScreen:onShow()
	
end

function vigScreen:update(dt)
	local mx,my = love.mouse.getPosition()
	mx,my = mx / love.graphics.getWidth(), my / love.graphics.getHeight()
	mx,my = mx - 0.5, my - 0.5
	self.cam.targetX = mx * 1920
	self.cam.targetY = my * 1080
	local weaveVal = self.lastUnderMouse == slider and 0.5 or 2
	self.cam.x = lerp(self.cam.x, self.cam.targetX, dt * weaveVal)
	self.cam.y = lerp(self.cam.y, self.cam.targetY, dt * weaveVal)
	
	for i,v in ipairs(self.roomObjects or {}) do
		local x,y = v.pos[1], v.pos[2]
		x = x - self.cam.x / v.pos[3]
		y = y - self.cam.y / v.pos[3]
		local d = v.drawPos or {x,y}
		v.drawPos = {x,y}--{lerp(d[1], x, dt * weaveVal), lerp(d[2],y,dt * weaveVal)}
	end
end

function vigScreen:showRects()
	local function newRect(x,y,w,h,rotation,color)
		return {x = x, y = y, w = w, h = h, r = rotation, color = color,scale = 0}
	end
	self.rects = {}
	table.insert(self.rects, newRect(150,265,380,500,(math.random() - 0.5) * 0.1,{0,255,255}))
	table.insert(self.rects, newRect(156,271,368,488,0,{255,255,255}))
	table.insert(self.rects, newRect(80,110,510,65,-0.1,{255,255,255}))
	table.insert(self.rects, newRect(86,116,522,77,-0.1 + (math.random() - 0.5) * 0.1, {0,0,0}))
	table.insert(self.rects, newRect(100,200,500,45, -0.2, {39,39,39}))
	
	self.rects.drawOrder = {1,2,5,3,4}
	self.textShown = false	
	slider.visible = false
	local function showRect(r,speed,interp)
		speed = speed or 1
		local t = 0
		while t < speed do
			r.scale = interp(t,0,1,speed,0.5,0.3)
			t = t + coroutine.yield()
		end
	end
	for i,v in ipairs(self.rects) do
		system.dispatch(false, function() showRect(v,0.3,outElastic) end)
		system.wait(0.1)
	end
	self.textShown = true
	slider.visible = true
	self.titleRotation = -0.1 + ((math.random() - 0.5) * 0.1)
end

function vigScreen:draw()
	if not self.scene then return end
	
	local lg = love.graphics
	lg.setColor(255,255,255)
	-- draw room objects
	table.sort(self.roomObjects, function(a,b) if a.pos[3] == b.pos[3] then return a.id > b.id else return a.pos[3] > b.pos[3] end end)
	lg.push() lg.translate(1920 / 2 , 1080 / 2)
	for i,v in ipairs(self.roomObjects or {}) do
		lg.draw(v.sprite,v.drawPos[1],v.drawPos[2],0,1,1,v.sprite:getWidth() / 2, v.sprite:getHeight() / 2)
	end
	lg.pop()
	
	--draw rects
	if self.rects then
		for i,vv in ipairs(self.rects.drawOrder) do
			local v = self.rects[vv]	
			lg.setColor(v.color[1],v.color[2],v.color[3],64)
			rotatedRect("fill",v.x,v.y,v.w,v.h,v.r,v.scale * 1.005)
			
			--lg.setColor(v.color[1],v.color[2],v.color[3],128)
			rotatedRect("fill",v.x,v.y,v.w,v.h,v.r,v.scale * 1.0025)
			lg.setColor(v.color)
			rotatedRect("fill",v.x,v.y,v.w,v.h,v.r,v.scale)
			
		end
	end
	
	if self.textShown then
		lg.setFont(self.fonts.title)
		lg.setColor(255,0,255)
		lg.print(self.vig.title:upper(),90,150,self.titleRotation)
		lg.setFont(self.fonts.subtitle)
		lg.setColor(200,200,200)
		lg.print(self.vig.subtitle:lower(),120,255,-0.2)
	end
	self:drawObjects()
	overlay:draw()
end

return vigScreen