
math.randomseed(os.time()) math.random() math.random() math.random() math.random()

local sin,pow,pi,sqrt,abs,asin = math.sin,math.pow,math.pi,math.sqrt,math.abs,math.asin

function table.random(t)
	return t[math.random(#t)]
end

function table.join(t,o)
	for i,v in pairs(o) do
		t[i] = v
	end
end

function HSL(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function clamp(val,min,max)
	if val > max then return max 
	elseif val < min then return min
	else return val end
end

function tri(a,b,c)
	return a + math.sqrt(math.random() * (b-a) * (c-a))
end

function lerp (a, b, t)
	return a + (b - a) * t
end 
 
function saturate(val)
	return clamp(val,0,1)
end
 
--- Smoothsteps a value
-- @param  edge0 Lower edge
-- @param  edge1 Upper edge
-- @param  x     Needle
-- @return       The smoothed value
function smoothstep(edge0, edge1, x)
    x = saturate((x - edge0) / (edge1 - edge0))
    return x * x * (3 - 2 * x)
end

--- Lerps a value with a smoothed needle
-- @param  a Lower edge
-- @param  b Upper edge
-- @param  t Needle
-- @return   A smoothly lerped value
function smoothlerp(a,b,t)
    return lerp(a,b,smoothstep(0,1,t))
end 

function berp(a,b,t)
	t = (math.sin(t * math.pi * (0.2 + 2.5 * t * t * t)) * (1 - t ^ 2.2) + t) * (1 + (1.2 * (1 - t)))
	return lerp(a,b,t)
end

function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end



function outSine(t, b, c, d) return c * sin(t / d * (pi / 2)) + b end
function outCirc(t, b, c, d)  return(c * sqrt(1 - pow(t / d - 1, 2)) + b) end
function linear(t, b, c, d) return c * t / d + b end

local function calculatePAS(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * pi) * asin(c/a) -- p,a,s
end
function inElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end
function outElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

function rotatedRect(style,x,y,w,h,r,s)
	local lg = love.graphics
	lg.push()
	lg.translate(x + w/2, y + h/2)
	lg.rotate(r)
	lg.scale(s)
	lg.rectangle(style, -w/2, -h/2, w, h)
	lg.pop()
end

function contains(px,py,x,y,w,h)
	return px > x and px < x + w and py > y and py < y + h
end

function deepcopy(o, seen)
  seen = seen or {}
  if o == nil then return nil end
  if seen[o] then return seen[o] end

  local no
  if type(o) == 'table' then
    no = {}
    seen[o] = no

    for k, v in next, o, nil do
      no[deepcopy(k, seen)] = deepcopy(v, seen)
    end
    setmetatable(no, deepcopy(getmetatable(o), seen))
  else -- number, string, boolean, etc
    no = o
  end
  return no
end