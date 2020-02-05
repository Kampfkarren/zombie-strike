local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Create = require(script.Parent.Create)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(e(Create, {
		FakeLevel = 50,
	}), target, "Create")

	return function()
		Roact.unmount(handle)
	end
end
