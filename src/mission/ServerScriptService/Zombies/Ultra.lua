local Common = require(script.Parent.Common)

local Shotgun = {}

function Shotgun.new(level)
	local derivative = Common.new(level)

	return setmetatable({
		Model = "Ultra",
		_derivative = derivative,
	}, {
		__index = derivative,
	})
end

return Shotgun
