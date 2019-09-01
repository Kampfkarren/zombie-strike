-- variables

local effects	= {}

-- module

local EFFECTS	= {}

function EFFECTS.Effect(self, effect, ...)
	if not effects[effect] then
		if script:FindFirstChild(effect) then
			effects[effect]	= require(script[effect])
		end
	end

	if effects[effect] then
		effects[effect](...)
	end
end

return EFFECTS