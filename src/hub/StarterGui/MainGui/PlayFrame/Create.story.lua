local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Create = require(script.Parent.Create)
local inspect = require(ReplicatedStorage.Core.inspect)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(e(Create, {
		FakeLevel = 50,

		OnSubmit = function(properties)
			print("Create submitted:", inspect(properties))
		end,
	}), target, "Create")

	return function()
		Roact.unmount(handle)
	end
end
