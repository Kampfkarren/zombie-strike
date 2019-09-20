local Common = require(script.Parent.Common)

local Strong = {}

Strong.Scaling = {
	Health = {
		Base = 175,
		Scale = 1.154,
	},

	Speed = {
		Base = 13.5,
		Scale = 1.01,
	},

	Damage = {
		Base = 55,
		Scale = 1.15,
	},
}

function Strong.new(level)
	return setmetatable({
		Model = "Strong",
		Name = "Strong Zombie",
		Scaling = Strong.Scaling,
	}, {
		__index = Common.new(level),
	})
end

return Strong
