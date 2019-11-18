local Common = require(script.Parent.Common)

local Fast = {}

function Fast:Wander()
	self:Aggro()
end

function Fast:GetDeathSound()
	local sound = self._derivative:GetDeathSound()

	local pitchShift = Instance.new("PitchShiftSoundEffect")
	pitchShift.Octave = 1.5
	pitchShift.Parent = sound

	return sound
end

function Fast.new(level)
	local derivative = Common.new(level)

	return setmetatable({
		Model = "Fast",
		Name = "Fast Zombie",
		_derivative = derivative,
	}, {
		__index = derivative,
	})
end

return Fast
