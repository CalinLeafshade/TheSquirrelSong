--bloom

local lg = love.graphics
local bloom = 
{
	shaders = 
	{
		blur = lg.newShader([[
	
			#define SAMPLE_COUNT 15

			extern vec2 SampleOffsets[SAMPLE_COUNT];
			extern float SampleWeights[SAMPLE_COUNT];
			
			vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 pos) {
				vec4 c = vec4(0,0,0,0);
				
				// Combine a number of weighted image filter taps.
				for (int i = 0; i < SAMPLE_COUNT; i++)
				{
						c += texture2D(tex, tex_coords + SampleOffsets[i]) * SampleWeights[i];
				}
				
				return c;
			}
		]]),
		cutoff = lg.newShader([[
			extern float cutoff;
			vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 pos) {
		 
					color = texture2D(tex, tex_coords);
		
				return clamp((color - cutoff) / (1 - cutoff),0.0,1.0);
			
			}
		]]),
		combine = lg.newShader([[

			extern Image BloomSampler;
			extern Image BaseSampler;

			extern float BloomIntensity;
			extern float BaseIntensity;

			extern float BloomSaturation;
			extern float BaseSaturation;


			// Helper for modifying the saturation of a color.
			vec4 AdjustSaturation(vec4 color, float saturation)
			{
					// The constants 0.3, 0.59, and 0.11 are chosen because the
					// human eye is more sensitive to green light, and less to blue.
					float grey = dot(color, vec4(0.3, 0.59, 0.11,0));

					return mix(vec4(grey), color, saturation);
			}
			
			vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 pos) {
				
				// Look up the bloom and original base image colors.
				vec4 bloom = texture2D(BloomSampler, texCoord);
				vec4 base = texture2D(BaseSampler, texCoord);
				
				
				// Adjust color saturation and intensity.
				bloom = AdjustSaturation(bloom, BloomSaturation) * BloomIntensity;
				base = AdjustSaturation(base, BaseSaturation) * BaseIntensity;
				
				// Darken down the base image in areas where there is a lot of bloom,
				// to prevent things looking excessively burned-out.
				base *= (1 - clamp(bloom,0.0,1.0));
				
				// Combine the two images.
				return base + bloom;
				
				}
			
		]])

	}
}
local shaders = bloom.shaders

local speedFactor = 4

bloom.scene = lg.newCanvas(1920,1080)
bloom.rt1 = lg.newCanvas(1920/speedFactor,1080/speedFactor)
bloom.rt2 = lg.newCanvas(1920/speedFactor,1080/speedFactor)

bloom.blurAmount = 1
bloom.threshold = 0.4

bloom.baseIntensity = 1
bloom.bloomIntensity = 3
bloom.baseSaturation = 1
bloom.bloomSaturation = 1
bloom.on = true

function bloom:toggle()
	self.on = not self.on
end

function bloom:can()
	if not self.on then return false end
	if not love.graphics.isSupported("shader") then
		return false
	end
	return true
end

function bloom:preDraw()
	--if not self:can() then return end
	--love.graphics.setBackgroundColor(0,0,0,0)
	self.origCanvas = lg.getCanvas()
	lg.setCanvas(self.scene)
	lg.clear()
end

function bloom:draw()
	--if not self:can() then return end
		
		shaders.cutoff:send("cutoff", self.threshold or 0.8)
		
		lg.setCanvas(self.rt1)
		lg.clear()
		lg.setShader(shaders.cutoff)
		lg.draw(self.scene,0,0,0,1/speedFactor,1/speedFactor)
		
		self:setBlur(1 / (1920 / speedFactor),0)
		
		lg.setCanvas(self.rt2)
		lg.clear()
		lg.setShader(shaders.blur)
		lg.draw(self.rt1,0,0)
		
		self:setBlur(0,1/ (1080 / speedFactor))
		
		lg.setCanvas(self.rt1)
		lg.clear()
		lg.setShader(shaders.blur)
		lg.draw(self.rt2,0,0)
		
		
		

	
	

	
end

function bloom:finalDraw(y)
	shaders.combine:send("BloomIntensity", self.bloomIntensity)
	shaders.combine:send("BaseIntensity", self.baseIntensity)
	shaders.combine:send("BloomSaturation", self.bloomSaturation)
	shaders.combine:send("BaseSaturation", self.baseSaturation)
		
	shaders.combine:send("BaseSampler", self.scene)
	shaders.combine:send("BloomSampler", self.rt1)
	
	lg.setShader(shaders.combine)
	
	lg.setCanvas(self.origCanvas)
	lg.draw(self.scene,0,0)
	
	lg.setShader()
end

function bloom:setBlur(dx,dy)
	
			
		local function gaussian(n)

			local theta = self.blurAmount;

			return ((1.0 / math.sqrt(2 * math.pi * theta)) * math.exp(-(n * n) / (2 * theta * theta)))
									 
		end

			local sampleCount = 15

			-- Create temporary arrays for computing our filter settings.
			local sampleWeights = {}
			local sampleOffsets = {}

			-- The first sample always has a zero offset.
			sampleWeights[0] = gaussian(0);
			sampleOffsets[0] = {0,0}

			-- Maintain a sum of all the weighting values.
			local totalWeights = sampleWeights[0];

			-- Add pairs of additional sample taps, positioned
			-- along a line in both directions from the center.
			for i = 0, sampleCount / 2 do
			
					-- Store weights for the positive and negative taps.
					local weight = gaussian(i + 1);

					sampleWeights[i * 2 + 1] = weight;
					sampleWeights[i * 2 + 2] = weight;

					totalWeights = totalWeights + weight * 2;

					--[[ To get the maximum amount of blurring from a limited number of
					// pixel shader samples, we take advantage of the bilinear filtering
					// hardware inside the texture fetch unit. If we position our texture
					// coordinates exactly halfway between two texels, the filtering unit
					// will average them for us, giving two samples for the price of one.
					// This allows us to step in units of two texels per sample, rather
					// than just one at a time. The 1.5 offset kicks things off by
					// positioning us nicely in between two texels.
					]]--
					local sampleOffset = i * 2 + 1.5

					local delta = {dx * sampleOffset, dy * sampleOffset}

					-- Store texture coordinate offsets for the positive and negative taps.
					sampleOffsets[i * 2 + 1] = delta;
					sampleOffsets[i * 2 + 2] = {-delta[1], -delta[2]}
			
			end

			-- Normalize the list of sample weightings, so they will always sum to one.
			for i=0,#sampleWeights do
				sampleWeights[i] = sampleWeights[i] / totalWeights
			end

			-- Tell the effect about our new filter settings.
			shaders.blur:send("SampleOffsets", unpack(sampleOffsets))
			shaders.blur:send("SampleWeights", unpack(sampleWeights))
			
end

return bloom

