-- variables

local effects = {}

-- module
local Effects = {}

Effects.EffectIDs = {
	Shoot = 1,
	Reload = 2,
	Explosion = 3,
	Shatter = 4,
	MinorExplosion = 5,
}

function Effects.Effect(_, effect, ...)
	if not effects[effect] then
		if script:FindFirstChild(effect) then
			effects[effect]	= require(script[effect])
		end
	end

	if effects[effect] then
		effects[effect](...)
	end
end

function Effects.EffectById(id, ...)
	for effect, effectId in pairs(Effects.EffectIDs) do
		if effectId == id then
			Effects.Effect(nil, effect, ...)
			break
		end
	end
end

return Effects