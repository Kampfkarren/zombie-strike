local Common = require(script.Parent.Common)

local Strong = {}

function Strong:GetDeathSound()
	local sound = self._derivative:GetDeathSound()

	local pitchShift = Instance.new("PitchShiftSoundEffect")
	pitchShift.Octave = 0.75
	pitchShift.Parent = sound

	return sound
end

function Strong.new(level)
	local derivative = Common.new(level)

	return setmetatable({
		Model = "Strong",
		Name = "Strong Zombie",
		Scaling = Strong.Scaling,
		_derivative = derivative,
	}, {
		__index = derivative,
	})
end

return Strong
