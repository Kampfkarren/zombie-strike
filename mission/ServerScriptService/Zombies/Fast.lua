local Common = require(script.Parent.Common)

local Fast = {}

Fast.Scaling = {
	Health = {
		Base = 55,
		Scale = 1.154,
	},

	Speed = {
		Base = 19.5,
		Scale = 1.01,
	},

	Damage = {
		Base = 20,
		Scale = 1.15,
	},
}

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
