
local screen = require('screen')

local birthScreen = screen()

local lg = love.graphics
local smoke = lg.newImage("gfx/smoke.png")
local bloom = require('bloom')
local font = lg.newFont("fonts/birth.tff",80)

local function getPS()
	
	local ps = lg.newParticleSystem(smoke,50)

	ps:setSizes(0.5,1.5,0.5)
	ps:setSizeVariation(1)
	ps:setColors(255,255,255,0,255,255,255,50,255,255,255,0)
	ps:setParticleLifetime(4,10)
	ps:setEmissionRate(30)
	ps:setSpeed(0,200)
	ps:setSpread(math.pi * 2)
	ps:setRotation(0,math.pi * 2)
	ps:setSpin(1)

	return ps
	
end

local ps1 = getPS()
local ps2 = getPS()
ps1:start()
ps2:start()

local cutoff = lg.newShader([[
	extern float cutoff;
	vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 pos) {
 
			color = texture2D(tex, tex_coords);

		return clamp((color - cutoff) / (1 - cutoff),0.0,1.0);
	
	}
]])

function birthScreen:update(dt)
	ps1:setPosition(math.random(1920), math.random(1080))
	ps1:update(dt)
	ps2:setPosition(math.random(1920), math.random(1080))
	ps2:update(dt)
end

function birthScreen:draw()
	
	bloom:preDraw()
	lg.draw(ps1,0,0)
	lg.setBlendMode("subtractive")
	lg.draw(ps2,0,0)
	lg.setBlendMode("alpha")
	lg.setFont(font)
	lg.print("This is some test text", 400, 1080 / 2 + math.sin(love.timer.getTime()) * 10)
	bloom:draw()
end

return birthScreen