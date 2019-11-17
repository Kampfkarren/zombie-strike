local Common = require(script.Parent.Common)

local Fast = {}

function Fast:Wander()
	self:Aggro()
end

function Fast.new(level)
	return setmetatable({
		Model = "Fast",
		Name = "Fast Zombie",
		Scaling = Fast.Scaling,
	}, {
		__index = Common.new(level),
	})
end

return Fast
