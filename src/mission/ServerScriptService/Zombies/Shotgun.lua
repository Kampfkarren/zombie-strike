local Gunslinger = require(script.Parent.Gunslinger)

local Shotgun = {}

function Shotgun.new(level)
	local derivative = Gunslinger.new(level)

	return setmetatable({
		Model = "Shotgun",
		_derivative = derivative,
	}, {
		__index = derivative,
	})
end

return Shotgun
