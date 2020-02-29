local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

return Roact.createContext({
	selectedFilter = {
		Name = "All",
		Filter = function()
			return true
		end,
	},
})
